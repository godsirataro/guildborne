"""Validate normalized quest/skill DAGs before writing Roblox content. No runtime writes."""
from __future__ import annotations


def validate(nodes: list[dict], *, kind: str = 'quest') -> dict:
    if kind not in ('quest', 'skill') or not isinstance(nodes, list) or len(nodes) > 512:
        raise ValueError('Expected quest or skill node list')
    by_id = {}
    for n in nodes:
        if not isinstance(n, dict) or not isinstance(n.get('id'), str) or not n['id'] or n['id'] in by_id:
            raise ValueError('Missing or duplicate node ID')
        by_id[n['id']] = n
        for f in ('level', 'hall'):
            v = n.get(f, 1 if f == 'level' else 0)
            limit = 100 if f == 'level' else 20
            if type(v) is not int or v < (1 if f == 'level' else 0) or v > limit:
                raise ValueError(f'Invalid {f} on {n["id"]}')
        if not isinstance(n.get('requires', []), list):
            raise ValueError('requires must be a list')
        if n.get('main', False) and any(n.get(x, False) for x in ('requiresPayment','requiresPlayerGuild','requiresMarket','requiresRandomHero')):
            raise ValueError('Main progression depends on payment/guild/market/random recruitment')
        if kind == 'quest' and n.get('reward') and not n.get('rewardReceiptKey'):
            raise ValueError('Reward needs stable server receipt key')
        if kind == 'skill' and (type(n.get('cost')) is not int or n['cost'] < 0):
            raise ValueError('Invalid skill cost')
    seen, active, ordered = set(), set(), []
    def visit(key):
        if not isinstance(key, str) or key not in by_id:
            raise ValueError(f'Missing node {key}')
        if key in active:
            raise ValueError(f'Cycle at {key}')
        if key in seen:
            return
        active.add(key)
        for dep in by_id[key].get('requires', []):
            visit(dep)
        active.remove(key); seen.add(key); ordered.append(key)
    for key in by_id:
        visit(key)
    cache = {}
    def ancestors(key):
        if key in cache: return cache[key]
        result = set()
        for dep in by_id[key].get('requires', []):
            result.add(dep); result.update(ancestors(dep))
        cache[key] = result
        return result
    for key, n in by_id.items():
        if kind == 'quest' and n.get('main', False):
            for dep in ancestors(key):
                if any(by_id[dep].get(x,False) for x in ('requiresPayment','requiresPlayerGuild','requiresMarket','requiresRandomHero')):
                    raise ValueError(f'{key}: transitive main-progression paywall')
        if kind == 'skill':
            groups = {}
            for p in ancestors(key) | {key}:
                group = by_id[p].get('exclusiveGroup')
                if group and group in groups and groups[group] != p:
                    raise ValueError(f'{key} requires mutually exclusive nodes')
                if group: groups[group] = p
        if kind == 'quest' and n.get('unlocksHall') is not None:
            unlock = n['unlocksHall']
            if type(unlock) is not int or not 1 <= unlock <= 20:
                raise ValueError('Invalid Hall unlock')
            previous_cap = 10 if unlock == 1 else min(100, 20 + 5*(unlock-2))
            chain = [by_id[p] for p in ancestors(key) | {key}]
            if any(p.get('level',1) > previous_cap or p.get('hall',0) >= unlock for p in chain):
                raise ValueError(f'{key}: Hall progression deadlock')
    return {'kind': kind, 'nodes': len(nodes), 'order': ordered,
            'scope': 'NORMALIZED_CONTENT_GRAPH_ONLY_NOT_GAMEPLAY_ACCEPTANCE'}
