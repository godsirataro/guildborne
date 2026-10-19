--!strict
-- Proposed shared daily activities, not reviewed travel routes or a runtime scheduler.
-- Existing FriendlyNpcs supplies every anchor/name; no new population or appearance IDs.
return table.freeze({
    Version=1, DaySeconds=86400, RecoverySeconds=.6,
    Ids=table.freeze({"borga","mogra","rukk","ghar","marshal_elian","arborist_vaela","smith_borin","cartographer_nyra","harbormaster_sela","steward_roka",
        "host_crownford","host_sylvaris","host_deepforge","host_astralis","host_crosshaven","host_ironroot"}),
    Phases=table.freeze({
        table.freeze({start=0,activity="Rest"}),
        table.freeze({start=21600,activity="Work"}),
        table.freeze({start=64800,activity="Social"}),
        table.freeze({start=79200,activity="Rest"}),
    }),
    NearEnter=50, NearExit=65, FarEnter=160, FarExit=140,
    -- Short stationary work bouts followed by an attentive pause. Offsets keep
    -- nearby residents from stopping together; the caller supplies server time.
    -- Pauses never close a service or move an actor away from a quest anchor.
    Routines=table.freeze({
        borga=table.freeze({work=32,pause=8,offset=0}),
        mogra=table.freeze({work=16,pause=8,offset=4}),
        rukk=table.freeze({work=16,pause=8,offset=12}),
        ghar=table.freeze({work=24,pause=8,offset=20}),
        marshal_elian=table.freeze({work=16,pause=8,offset=0}),
        arborist_vaela=table.freeze({work=24,pause=8,offset=8}),
        smith_borin=table.freeze({work=24,pause=8,offset=16}),
        cartographer_nyra=table.freeze({work=16,pause=8,offset=8}),
        harbormaster_sela=table.freeze({work=16,pause=8,offset=16}),
        steward_roka=table.freeze({work=24,pause=8,offset=24}),
        host_crownford=table.freeze({work=16,pause=8,offset=12}),
        host_sylvaris=table.freeze({work=24,pause=8,offset=20}),
        host_deepforge=table.freeze({work=24,pause=8,offset=4}),
        host_astralis=table.freeze({work=16,pause=8,offset=20}),
        host_crosshaven=table.freeze({work=16,pause=8,offset=4}),
        host_ironroot=table.freeze({work=24,pause=8,offset=12}),
    }),
})
