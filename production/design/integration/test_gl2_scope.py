"""Regression cases for preventing accidental return to the retired Lv35 Public scope."""
import copy
import unittest

from validate_gl2 import documents, validate


class ScopeTests(unittest.TestCase):
    def setUp(self):
        self.docs = copy.deepcopy(documents())

    def rejected(self, expected):
        self.assertTrue(any(expected in error for error in validate(*self.docs)), validate(*self.docs))

    def test_current_metadata(self):
        self.assertEqual(validate(*self.docs), [])

    def test_lv35_public_regression(self):
        self.docs[2]["publicMaxLevel"] = 35
        self.rejected("Public must require Lv100")

    def test_market_deferred(self):
        row = next(row for row in self.docs[2]["items"] if row["id"] == "player-market")
        row.update(phase="post", requiredBeforePublic=False)
        self.rejected("player-market: missing required")

    def test_missing_federation(self):
        self.docs[0]["groups"] = [row for row in self.docs[0]["groups"] if row["id"] != "federation"]
        self.rejected("group inventory incomplete")

    def test_p9_cannot_skip_war(self):
        next(row for row in self.docs[0]["phases"] if row["id"] == "P9")["dependsOn"].remove("P6")
        self.rejected("P9: missing required")

    def test_art_must_start_early(self):
        next(row for row in self.docs[0]["groups"] if row["id"] == "cities-world")["startsAt"] = "P8"
        self.rejected("art must start atP1")

    def test_proposal_cannot_close_p0(self):
        self.docs[0]["p0Complete"] = True
        self.rejected("P0 cannot close")

    def test_required_website_cannot_be_optional(self):
        next(row for row in self.docs[1]["features"] if row["id"] == "19")["releaseGate"] = "optional"
        self.rejected("feature19: not required")

    def test_cycles_and_unknown_dependencies(self):
        self.docs[0]["groups"][0]["foundationDependencies"] = ["campaign", "imaginary"]
        self.rejected("cycle")
        self.rejected("unknown dependency imaginary")

    def test_nonexistent_source_is_not_evidence(self):
        self.docs[0]["groups"][0]["sourcePaths"] = ["src/missing-gl2-service.luau"]
        self.rejected("missing/outside source")

    def test_duplicate_feature_and_fake_task(self):
        self.docs[1]["features"].append(copy.deepcopy(self.docs[1]["features"][0]))
        self.docs[0]["groups"][0]["forgeTasks"] = ["nonexistent-gl2-task"]
        self.rejected("duplicate ID")
        self.rejected("unknown/missing Forge task")

    def test_metadata_cannot_authorize_public(self):
        self.docs[0]["publicReady"] = True
        self.rejected("cannot approve Public")

    def test_war_cannot_skip_shared_qualification(self):
        next(row for row in self.docs[0]["phases"] if row["id"] == "P6")["dependsOn"] = []
        self.rejected("P6: missing required")

    def test_endgame_completion_needs_campaign_and_shared_rewards(self):
        next(row for row in self.docs[0]["phases"] if row["id"] == "P5")["dependsOn"] = ["P2"]
        self.rejected("P5: missing required")

    def test_early_guild_foundation_is_not_p5_start(self):
        next(row for row in self.docs[0]["groups"] if row["id"] == "personal-guild")["startsAt"] = "P5"
        self.rejected("foundations start too late")

    def test_start_cannot_follow_completion(self):
        self.docs[0]["groups"][0]["startsAt"] = "P10"
        self.rejected("starts after its completion")


if __name__ == "__main__":
    unittest.main()
