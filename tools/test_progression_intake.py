"""Adversarial design-audit fixtures. Source drafts stay read-only."""
import copy,unittest
from validate_progression_intake import audit,load

class AuditTests(unittest.TestCase):
    def setUp(self):self.rules,self.classes,self.quests=copy.deepcopy(load())
    def codes(self):return {e['code'] for e in audit(self.rules,self.classes,self.quests)['errors']}
    def test_source_is_unchanged(self):
        before=copy.deepcopy((self.rules,self.classes,self.quests));audit(self.rules,self.classes,self.quests)
        self.assertEqual(before,(self.rules,self.classes,self.quests))
    def test_indirect_quest_cycle(self):
        self.quests[0]['prerequisite_design_ids']=[self.quests[2]['id']]
        self.assertIn('quest_cycle',self.codes())
    def test_unknown_gate(self):
        self.quests[0]['prerequisite_design_ids']=['MISSING']
        self.assertIn('missing_prerequisite',self.codes())
    def test_self_locked_hall(self):
        self.rules['hall_schedule'][1]['minimum_player_level']=25
        self.assertIn('hall_level_deadlock',self.codes())
    def test_cross_class_parent(self):
        child=next(c for c in self.classes if c['tier']==2);child['parent_id']='mage'
        self.assertIn('class_parent_mismatch',self.codes())
    def test_accidental_extra_points(self):
        self.rules['status_points']['level100']=300
        self.assertIn('ap_budget_mismatch',self.codes())
    def test_no_runtime_readiness_from_design_counts(self):
        report=audit(self.rules,self.classes,self.quests)
        self.assertFalse(report['runtimeReady']);self.assertEqual(len(report['unboundQuests']),240)

if __name__=='__main__':unittest.main()
