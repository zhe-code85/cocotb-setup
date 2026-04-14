#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path

from cocotb_tools.runner import get_runner


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the tiny counter cocotb demo")
    parser.add_argument(
        "--sim",
        choices=("verilator", "vcs"),
        required=True,
        help="Simulator to use",
    )
    args = parser.parse_args()

    example_dir = Path(__file__).resolve().parent
    tests_dir = example_dir / "tests"
    build_dir = example_dir / "sim_build" / args.sim
    build_args = []

    sys.path.insert(0, str(tests_dir))

    if args.sim == "vcs":
        build_args = ["-timescale=1ns/1ps"]

    runner = get_runner(args.sim)
    runner.build(
        sources=[example_dir / "rtl" / "tiny_counter.v"],
        hdl_toplevel="tiny_counter",
        build_dir=build_dir,
        always=True,
        clean=True,
        build_args=build_args,
        waves=(args.sim == "verilator"),
    )
    runner.test(
        hdl_toplevel="tiny_counter",
        test_module="test_tiny_counter",
        build_dir=build_dir,
        test_dir=tests_dir,
        waves=(args.sim == "verilator"),
    )


if __name__ == "__main__":
    main()
