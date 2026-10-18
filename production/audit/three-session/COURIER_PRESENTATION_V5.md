# Courier presentation wiring — v5 review

S17 e960344 independently reviewed and integrated as a15006c. Only NoviceCourseWorld and owned evidence changed. Courier uses WorkMotionIdentity=marshal_elian without changing Name/DesignId/Owner or setting canonical NpcId. Existing owner/live-root/12-stud/current-objective guards now also require Active and no pending observation before presentation. Greeting/interaction hints follow queued observation and share one clock; they are NOT a reward/commit confirmation. Rejected delivery may still leave a12-second greeting. Existing entry invalidation/heartbeat behavior is unchanged.

Controller reran4pureidentitytests and compile successfully. Worker recorded scoped analysis/compile receipt2ccd3415d38744448f434b1f65887ab9. Independent controller review found no new blocker; those pure tests do not verify prompt callbacks. Full combined baseline and actual new-source callback matrix remain pending with the current other workers.

Actual visual check used a CLIENT-ONLY clone of the current real courier in Studio62789207-389b-45dc-95a0-c5bffd63cd0b, with candidate presentation alias applied. It did not patch the live server callback or alter original actor/profile/progression. Actual FriendlyNpcAnimator drove the native kit; synthetic GreetingAt/NpcInteractUntil/NpcInteractor stimulated presentation only. Raw receipts: courier-visual-v5.json.

Observed work→talk→recovered work weight0→1,12-second hint expiry, root position delta0,player position delta0, both upper/lower leg motor deltas0. RightUpperArm work sample(-.2543,0,-.1356) after expiry; talk sample arm wave while workWeight0. This proves this kit can consume existing motion and return without root/leg displacement, not natural final-art approval or callback security.

Captures courier_letter_work_v5, courier_letter_talk_v5 and explicit-camera courier_letter_close_work_v5 inspected. First two wider images were affected by the existing game camera; the final close capture used camera(-4420.55,4,86.53) toward(-4423.55,3,80.53). Native courier remains stylized block geometry; letter/satchel are present. No imported body, hand-contact measurement or human approval claimed.

Clone and temporary camera/GUI storage destroyed;12ScreenGui states restored. Separate read confirmed fixture absent, management visible, original actor has no added motion alias, player still(-4423.5527,2.998,88.5282). Earned Chapter3 session preserved. S17 scope released after integration. S13art/S14card/S15BasicVFX remain active and unintegrated at this checkpoint.
