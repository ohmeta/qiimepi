#!/usr/bin/env python

import argparse
import os
import subprocess
import sys
import textwrap
from io import StringIO

import pandas as pd

import qiimepi


AMPLICON_WF = [
    "qiime2_import_all",
    "qiime2_denoise_all",
    "qiime2_feature_all",
    "qiime2_taxonomic_all",
    "qiime2_phylotree_all",
    "qiime2_function_all",
    "all",
]


def run_snakemake(args, unknown, snakefile, workflow):
    conf = qiimepi.parse_yaml(args.config)

    if not os.path.exists(conf["params"]["samples"]):
        print("Please specific samples list on init step or change config.yaml manualy")
        sys.exit(1)

    cmd = [
        "snakemake",
        "--snakefile",
        snakefile,
        "--configfile",
        args.config,
        "--cores",
        str(args.cores),
        "--until",
        args.task
    ] + unknown

    if "--touch" in unknown:
        pass
    elif args.conda_create_envs_only:
        cmd += ["--use-conda", "--conda-create-envs-only"]
        if args.conda_prefix is not None:
            cmd += ["--conda-prefix", args.conda_prefix]
    else:
        cmd += [
            "--rerun-incomplete",
            "--keep-going",
            "--printshellcmds",
            "--reason",
        ]

        if args.use_conda:
            cmd += ["--use-conda"]
            if args.conda_prefix is not None:
                cmd += ["--conda-prefix", args.conda_prefix]

        if args.list:
            cmd += ["--list"]
        elif args.run_local:
            cmd += ["--local-cores", str(args.local_cores),
                    "--jobs", str(args.jobs)]
        elif args.run_remote:
            profile_path = os.path.join("./profiles", args.cluster_engine)
            cmd += ["--profile", profile_path,
                    "--local-cores", str(args.local_cores),
                    "--jobs", str(args.jobs)]
        elif args.debug:
            cmd += ["--debug-dag"]
        else:
            cmd += ["--dry-run"]

        if args.dry_run and ("--dry-run" not in cmd):
            cmd += ["--dry-run"]

    cmd_str = " ".join(cmd).strip()
    print("Running qiimepi %s:\n%s" % (workflow, cmd_str))

    env = os.environ.copy()
    proc = subprocess.Popen(
        cmd_str,
        shell=True,
        stdout=sys.stdout,
        stderr=sys.stderr,
        env=env,
    )
    proc.communicate()

    print(f'''\nReal running cmd:\n{cmd_str}''')


def init(args, unknown):
    if args.workdir:
        project = qiimepi.qiimepi_config(args.workdir)
        print(project.__str__())
        project.create_dirs()
        conf = project.get_config()

        for env_name in conf["envs"]:
            conf["envs"][env_name] = os.path.join(
                os.path.realpath(args.workdir), f"envs/{env_name}.yaml"
            )

        if args.samples:
            conf["params"]["samples"] = args.samples
        else:
            print("Please supply samples table")
            sys.exit(-1)

        qiimepi.update_config(
            project.config_file, project.new_config_file, conf, remove=False
        )
    else:
        print("Please supply a workdir!")
        sys.exit(-1)


def amplicon_wf(args, unknown):
    snakefile = os.path.join(os.path.dirname(__file__), "snakefiles/amplicon_wf.smk")
    run_snakemake(args, unknown, snakefile, "amplicon_wf")


def snakemake_summary(snakefile, configfile, task):
    cmd = [
        "snakemake",
        "--snakefile",
        snakefile,
        "--configfile",
        configfile,
        "--until",
        task,
        "--summary",
    ]
    cmd_out = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    summary = pd.read_csv(StringIO(cmd_out.stdout.read().decode()), sep="\t")
    return summary


def main():
    banner = """

     ██████╗ ██╗██╗███╗   ███╗███████╗██████╗ ██╗
    ██╔═══██╗██║██║████╗ ████║██╔════╝██╔══██╗██║
    ██║   ██║██║██║██╔████╔██║█████╗  ██████╔╝██║
    ██║▄▄ ██║██║██║██║╚██╔╝██║██╔══╝  ██╔═══╝ ██║
    ╚██████╔╝██║██║██║ ╚═╝ ██║███████╗██║     ██║
     ╚══▀▀═╝ ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝

        Omics for All, Open Source for All

    Quantitative Insights Into Microbial Ecology

"""

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(banner),
        prog="qiimepi",
    )
    parser.add_argument(
        "-v",
        "--version",
        action="store_true",
        default=False,
        help="print software version and exit",
    )

    common_parser = argparse.ArgumentParser(add_help=False)
    common_parser.add_argument(
        "-d",
        "--workdir",
        metavar="WORKDIR",
        type=str,
        default="./",
        help="project workdir",
    )
    common_parser.add_argument(
        "--check-samples",
        dest="check_samples",
        default=False,
        action="store_true",
        help="check samples, default: False",
    )

    run_parser = argparse.ArgumentParser(add_help=False)
    run_parser.add_argument(
        "--config",
        type=str,
        default="./config.yaml",
        help="config.yaml",
    )
    run_parser.add_argument(
        "--cores",
        type=int,
        default=32,
        help="all job cores, available on '--run-local'")
    run_parser.add_argument(
        "--local-cores",
        type=int,
        dest="local_cores",
        default=8,
        help="local job cores, available on '--run-remote'")
    run_parser.add_argument(
        "--jobs",
        type=int,
        default=80,
        help="cluster job numbers, available on '--run-remote'")
    run_parser.add_argument(
        "--list",
        default=False,
        action="store_true",
        help="list pipeline rules",
    )
    run_parser.add_argument(
        "--debug",
        default=False,
        action="store_true",
        help="debug pipeline",
    )
    run_parser.add_argument(
        "--dry-run",
        default=False,
        dest="dry_run",
        action="store_true",
        help="dry run pipeline",
    )
    run_parser.add_argument(
        "--run-local",
        default=False,
        dest="run_local",
        action="store_true",
        help="run pipeline on local computer",
    )
    run_parser.add_argument(
        "--run-remote",
        default=False,
        dest="run_remote",
        action="store_true",
        help="run pipeline on remote cluster",
    )
    run_parser.add_argument(
        "--cluster-engine",
        default="slurm",
        dest="cluster_engine",
        choices=["slurm", "sge", "lsf", "pbs-torque"],
        help="cluster workflow manager engine, support slurm(sbatch) and sge(qsub)"
    )
    run_parser.add_argument("--wait", type=int, default=60, help="wait given seconds")
    run_parser.add_argument(
        "--use-conda",
        default=False,
        dest="use_conda",
        action="store_true",
        help="use conda environment",
    )
    run_parser.add_argument(
        "--conda-prefix",
        default="~/.conda/envs",
        dest="conda_prefix",
        help="conda environment prefix",
    )
    run_parser.add_argument(
        "--conda-create-envs-only",
        default=False,
        dest="conda_create_envs_only",
        action="store_true",
        help="conda create environments only",
    )

    subparsers = parser.add_subparsers(title="available subcommands", metavar="")
    parser_init = subparsers.add_parser(
        "init",
        formatter_class=qiimepi.custom_help_formatter,
        parents=[common_parser],
        prog="qiimepi init",
        help="init project",
    )
    parser_amplicon_wf = subparsers.add_parser(
        "amplicon_wf",
        formatter_class=qiimepi.custom_help_formatter,
        parents=[common_parser, run_parser],
        prog="qiimepi amplicon_wf",
        help="amplicon data analysis pipeline using QIIME2",
    )

    parser_init.add_argument(
        "-s",
        "--samples",
        type=str,
        default=None,
        help="""desired input:
samples list, tsv format required.
    if it is fastq:
        the header is: [id, fq1, fq2]
    if it is sra:
        the header is: [id, sra]
""",
    )
    parser_init.set_defaults(func=init)

    parser_amplicon_wf.add_argument(
        "task",
        metavar="TASK",
        nargs="?",
        type=str,
        default="all",
        choices=AMPLICON_WF,
        help="pipeline end point. Allowed values are " + ", ".join(AMPLICON_WF),
    )
    parser_amplicon_wf.set_defaults(func=amplicon_wf)

    args, unknown = parser.parse_known_args()

    try:
        if args.version:
            print("qiimepi version %s" % qiimepi.__version__)
            sys.exit(0)
        args.func(args, unknown)
    except AttributeError as e:
        print(e)
        parser.print_help()


if __name__ == "__main__":
    main()
