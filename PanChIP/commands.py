import argparse
import textwrap
import sys

def panchip_parser():
    usage = '''\
        panchip <command> [options]
        Commands:
            init            Initialization of the PanChIP library
            analysis        Analysis of a list peat sets
        Run panchip <command> -h for help on a specific command.
        '''
    parser = argparse.ArgumentParser(
        description='PanChIP: Pan-ChIP-seq Analysis of Peak Sets',
        usage=textwrap.dedent(usage)
    )

    from .version import __version__
    parser.add_argument('--version', action='version', version=f'PanChIP {__version__}')

    return parser

def init_parser():
    parser = MyParser(
        description='Initialization of the PanChIP library',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        'output_directory',
        type=str,
        help='Output directory wherein PanChIP library will be stored (> 4.2 GB of storage required).'

    return parser
      
def analysis_parser():
    parser = MyParser(
        description='Analysis of a list peat sets',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        'input_directory',
        type=str,
        help='Input directory wherein peak sets in the format of .bed files are located.'

    return parser