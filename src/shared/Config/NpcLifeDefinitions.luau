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
})
