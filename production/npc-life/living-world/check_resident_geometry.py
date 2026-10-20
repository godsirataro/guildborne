"""Source-bound analytic geometry checks, not Roblox construction/render evidence."""
from pathlib import Path
import math
import re
import unittest

ROOT = Path(__file__).resolve().parents[3]
WORLD = (ROOT / 'src/server/Services/CentralCityWorld.luau').read_text(encoding='utf-8')
RIG = (ROOT / 'src/server/Services/HeroRig.luau').read_text(encoding='utf-8')
ANIM = (ROOT / 'src/client/Controllers/FriendlyNpcAnimator.luau').read_text(encoding='utf-8')


def vector(text):
    return tuple(float(x) for x in text.split(','))


def xyz_part(name):
    match = re.search(r'detail\("' + name + r'",V\(([^)]+)\),V\(side\*([\d.]+),([\d.]+),([\d.]+)\)', RIG)
    if not match:
        raise AssertionError('HeroRig fixture binding changed: ' + name)
    return vector(match[1]), tuple(float(match[i]) for i in (2, 3, 4))


def hand_radius(angle):
    size, center = xyz_part('Hand')
    # Existing shoulder pivot must still match this independent rigid-body solve.
    assert 'V(-1.4,.8,0)' in RIG and 'V(0,3,0)' in RIG
    relative_y = center[1] - 3.8
    z = math.sin(angle) * relative_y + math.cos(angle) * center[2]
    half_z = abs(math.sin(angle)) * size[1] / 2 + abs(math.cos(angle)) * size[2] / 2
    x = abs(center[0]) + size[0] / 2
    return math.hypot(x, abs(z) + half_z)


class ResidentGeometry(unittest.TestCase):
    def test_authored_grip_and_gait_fit_with_reviewed_reserve(self):
        angle = float(re.search(r'local carryAngle=([\d.]+)', WORLD)[1])
        gait = float(re.search(r'Left Shoulder" then offset=CFrame.Angles\(wave\*([\d.]+)', ANIM)[1])
        reserve = float(re.search(r'math.sqrt\(x\*x\+z\*z\)\+([\d.]+)>3', WORLD)[1])
        for i in range(361):
            posed = angle + gait * math.sin(math.radians(i))
            self.assertLessEqual(hand_radius(posed) + reserve, 3)
        # Regression control: the tempting horizontal-arm preset actually fails.
        self.assertGreater(hand_radius(math.pi / 2) + reserve, 3)

    def test_tally_is_on_the_readable_upper_face(self):
        slate = re.search(r'"StockSlate",V\(([^)]+)\),porterArm,CFrame.new\(([^)]+)\)', WORLD)
        marks = re.search(r'"SlateTally",V\(([^)]+)\),porterArm,CFrame.new\(([^)]+)\)', WORLD)
        slate_size, slate_pos = vector(slate[1]), vector(slate[2])
        mark_size, mark_pos = vector(marks[1]), vector(marks[2])
        self.assertGreater(mark_pos[1] - mark_size[1] / 2, slate_pos[1] + slate_size[1] / 2)
        self.assertLess(mark_pos[1] - mark_size[1] / 2 - slate_pos[1] - slate_size[1] / 2, .02)

    def test_gauge_jaws_close_around_sample_without_crossing_it(self):
        sample = re.search(r'"SteelSample",V\(([^)]+)\)', WORLD)
        fixed = re.search(r'"FixedGaugeJaw",V\(([^)]+)\),gauge,CFrame.new\(([^)]+)\)', WORLD)
        moving = re.search(r'"SlidingGaugeJaw",V\(([^)]+)\)', WORLD)
        start = re.search(r'joint.C0=CFrame.new\(-.55,-.2,(-[\d.]+)\)', WORLD)
        stroke = re.search(r'InspectionJaw" then offset=CFrame.new\(0,0,([\d.]+)\*inspection\)', ANIM)
        sample_half = vector(sample[1])[2] / 2
        fixed_inner = vector(fixed[2])[2] - vector(fixed[1])[2] / 2
        moving_inner = float(start[1]) + float(stroke[1]) + vector(moving[1])[2] / 2
        self.assertGreaterEqual(fixed_inner, sample_half)
        self.assertLessEqual(moving_inner, -sample_half)
        self.assertLess(fixed_inner - sample_half, .01)
        self.assertLess(-sample_half - moving_inner, .01)


if __name__ == '__main__':
    unittest.main(verbosity=2)
