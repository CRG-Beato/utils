#!/usr/bin/python



#==================================================================================================
# Created on: 2017-12-13
# Usage: 
# Author: javier.quilez@crg.eu
# Goal:
#==================================================================================================




#==================================================================================================
# Configuration
#==================================================================================================

# load python packages
import os
import os.path
import pandas as pd
import glob
from scipy import stats
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


# matplotlib options
plt.rcParams['font.size'] = 20 
plt.rcParams['font.weight'] = 'medium' 
plt.rcParams['font.family'] = 'sans-serif' 
plt.rcParams['font.sans-serif'] = 'Arial' 
plt.rcParams['lines.linewidth'] = 2.0
plt.rcParams['legend.numpoints'] = 1
plt.rcParams['legend.frameon'] = False
plt.rcParams['savefig.bbox'] = 'tight'


# seaborn options
sns.set_context("talk", font_scale = 1.5)
sns.set_style("white")


def get_fastqc_directories(data_type, step, samples):

    '''
    Get list of FastQC reports
    '''
    
    # load python packages
    import glob
    
    
    fastqc_dirs = []

    for s in samples:
        
        if data_type == 'hic':
        
            if step == 'raw':
            
                MOUNT = '/Volumes/users-project-4DGenome'
                labels = (MOUNT, s)
                IDIR = '%s/sequencing/*/fastqc/%s_read*_fastqc' % labels
                _ = glob.glob(IDIR)

            elif step == 'processed':

                MOUNT = '/Volumes/users-project-4DGenome_no_backup'
                labels = (MOUNT, s, s)
                IDIR = '%s/data/hic/samples/%s/fastqs_processed/trimmomatic/*/%s_read*_fastqc' % labels
                _ = glob.glob(IDIR)

            fastqc_dirs = fastqc_dirs + _

    return sorted(fastqc_dirs)




#==================================================================================================
# Parse data from FastQC report
#==================================================================================================

def basic_statistics(data_type, step, samples):

    '''
    Summarize the Basic statistics module
    '''
    
    
    # load python packages    

    import pandas as pd
    

    # Prepare data

    # get the directories with the FastQC reports
    fastqc_dirs = get_fastqc_directories(data_type, step, samples)
       
    # import and combine data
    i = 0
    for d in fastqc_dirs:
            
        # read in file
        ifile = '%s/summary.txt' % d
        _ = pd.read_table(ifile, header = None)
        _.columns = ['flag', 'metric', 'file_id']
        file_id = list(set(_['file_id']))[0].replace('.fastq.gz', '')
        _.columns = [file_id, 'flag', 'file_id']
        _ = _[['flag', file_id]]

        # combine
        if i == 0:
            df = _.copy()
        else:
            df = pd.merge(df, _, on = 'flag')
        i += 1

    # re-format
    df.replace('PASS', 1, inplace = True)
    df.replace('WARN', 0, inplace = True)
    df.replace('FAIL', -1, inplace = True)
    df = df.set_index('flag')
    df = df.transpose()
    df = df.sort_index()
 
    return df


def total_number_sequences(data_type, step, samples):

    '''
    Get the total number of reads per FASTQ file
    '''

    
    # get the directories with the FastQC reports

    fastqc_dirs = get_fastqc_directories(data_type, step, samples)
    
    
    # import data

    i = 0
    file_ids = []
    n_seqs = []
    for d in fastqc_dirs:
            
        # read in file
        ifile = '%s/fastqc_data.txt' % d
        with open(ifile) as f:

            i = 0
            while i < 2:
            
                line = f.readline()
                line = line.rstrip()
                
                if line.startswith('Filename'):

                    file_id = line.split('\t')[1].replace('.fastq.gz', '')
                    i += 1
                    
                elif line.startswith('Total Sequences'):
                    
                    n = int(line.split('\t')[1]) / 1e6
                    i += 1
                    
        file_ids.append(file_id)            
        n_seqs.append(n)
      
    
    # combine data
    
    df = pd.DataFrame(n_seqs, index = file_ids).reset_index()
    df.columns = ['file_id', 'number_sequences_millions']
    df.sort_values(['file_id'], inplace = True)
 
    return df


def parse_data_from_fastqc_report(data_type, step, samples):
    
    '''
    Parse data from the FastQC report  
    '''

    
    # get the directories with the FastQC reports

    fastqc_dirs = get_fastqc_directories(data_type, step, samples)    
    
    
    # dictionary to store the data frames and flags
    
    fastqc_data = {}

    
    # store basic statistics
    
    fastqc_data['Basic statistics'] = basic_statistics(data_type, step, samples)
    
    
    # store the total number of sequences
    
    fastqc_data['Total number of sequences'] = total_number_sequences(data_type, step, samples)
    
    
    # FastQC modules
    
    fastqc_modules = ['Per base sequence quality',
                      'Per tile sequence quality',
                      'Per sequence quality scores',
                      'Per base sequence content',
                      'Per sequence GC content',
                      'Per base N content',
                      'Sequence Length Distribution',
                      'Sequence Duplication Levels',
                      'Overrepresented sequences',
                      'Adapter Content',
                      'Kmer Content']

                      
                      
    # import data
    
    for m in fastqc_modules:

        k = 1
        df = pd.DataFrame()
        for d in fastqc_dirs:

            ifile = '%s/fastqc_data.txt' % d

            # get the line numbers between which the rows we want are located
            with open(ifile) as f:
            
                row = 0
                start = 0
                end = 0
                while start + end < 2:
            
                    line = f.readline()
                    line = line.rstrip()
                    row += 1
                
                    if line.startswith('Filename'):

                        file_id = line.split('\t')[1].replace('.fastq.gz', '')
                    
                    elif line.startswith('>>%s' % m):
                    
                        start = 1
                        skip = row

                    elif line.startswith('#Total Deduplicated Percentage'):
                    
                        dedup_perc = float(line.split('\t')[1])

                    elif line.startswith('>>END_MODULE'):
                
                        if start == 1:
                        
                            end = 1
                            nrows = row


            # read in file and combine with previous samples
            if (m == 'Overrepresented sequences') and (nrows - skip) <= 1:
                continue
            if m == 'Sequence Duplication Levels':
                _ = pd.read_table(ifile, skiprows = skip + 1, nrows = nrows - skip - 3)
                _['file_id'] = file_id
                _['dedup_perc'] = dedup_perc
                df = pd.concat([df, _])
            else:
                _ = pd.read_table(ifile, skiprows = skip, nrows = nrows - skip - 2)
                _['file_id'] = file_id
                df = pd.concat([df, _])
                        
        fastqc_data[m] = df
        
    return fastqc_data




#==================================================================================================
# Plot metrics
#==================================================================================================

def plot_basic_statistics(fastqc_data, panel):
    
    '''
    Plot heatmap with the flags obtained for each metric
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    
    
    # load data
    
    df = fastqc_data['Basic statistics'].copy()
    
    
    # heat map
    g = sns.heatmap(df, cmap = ListedColormap(['red', 'orange', 'green']), square = True,
               ax = panel, alpha = 0.50, cbar = False)
    panel.set_xlabel('')
    panel.xaxis.tick_top()
    g.set_xticklabels(g.get_xticklabels(), rotation = 90)
    
    
    # add module name   
    panel.text(0.50, 1.65, "Basic statistics", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)    


def plot_total_number_of_sequences(fastqc_data, panel_a, panel_b):
    
    '''
    Plot barplot with the total number of sequences per file and
    and a boxplot with the overall distribution
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    
    
    # load data
    
    df = fastqc_data['Total number of sequences'].copy()   
    
        
    # barplot
    sns.barplot(y = 'file_id', x = 'number_sequences_millions', data = df, ax = panel_a,
                orient = 'h', palette = sns.color_palette("Paired", len(df) / 2))
    panel_a.set_xlabel('Total number of reads (millions)', labelpad = 50, weight = 'bold',
                      fontsize = 24)
    panel_a.set_ylabel('')
    panel_a.set_xlim(0, max(df['number_sequences_millions']) * 1.10)
    panel_a.axes.xaxis.set_ticklabels([])
    panel_a.set_xlabel('')
    
    # boxplot
    sns.boxplot(x = 'number_sequences_millions', data = df, ax = panel_b, color = 'lightgray',
               width = 0.50)
    sns.stripplot(x = 'number_sequences_millions', data = df, ax = panel_b, color = 'gray'
                  , jitter = True, size = 10)
    panel_b.set_xlim(0, max(df['number_sequences_millions']) * 1.10)
    panel_b.set_ylabel('')
    panel_b.set_xlabel('Number of reads (millions)', labelpad = 25)
    
    # add module name   
    panel_a.text(0.50, 1.10, "Total number of sequences", transform = panel_a.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)    


def plot_per_base_sequence_quality(fastqc_data, panel):
 
    
    '''
    Median per base sequence quality along the position in the read
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    
    
    # load data and flags
    m = 'Per base sequence quality'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()    
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'
    
        
    for s in flags.index:
        
        # subset data
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        panel.plot(_['#Base'], _['Mean'], color = flag_to_color[flag], alpha = 0.50)
        if (flag == '0') or (flag == '-1'):
            panel.text(_['#Base'][0], _['Mean'][0] - 2, file_id, color = flag_to_color[flag],
                    fontsize = 12)
    
    
    # labels and decorations
    
    panel.set_ylim(0, 36)
    panel.set_xlim(0, )
    panel.set_ylabel('Sequence quality', labelpad = 25)
    panel.set_xlabel('Position in read (bp)', labelpad = 25)
    panel.text(1, 7, 'Pass', color = 'Green', alpha = 0.75, horizontalalignment = 'left', 
               fontsize = 16)
    panel.text(1, 4, 'Warn', color = 'orange', alpha = 0.75, horizontalalignment = 'left',
               fontsize = 16)
    panel.text(1, 1, 'Fail', color = 'Red', alpha = 0.75, horizontalalignment = 'left', 
               fontsize = 16)
    

    # add module name
    
    panel.text(0.50, 1.10, "Per base sequence quality", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_per_tile_sequence_quality(fastqc_data, panel):
    
    '''
    Per tile sequence quality
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    
    
    # load data
    m = 'Per tile sequence quality'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'
    
    k = 1    
    for s in flags.index:
        
        # subset data
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        
        # plot
        panel.scatter(_['#Tile'] + _['Base'], _['Mean'], color = flag_to_color[flag],
                   alpha = 0.10, s = 10)       
        if (flag == '0') or (flag == '-1'):
            panel.text(1.05, k - 0.05, s, color = flag_to_color[flag],
                       transform = panel.transAxes, fontsize = 12)
            k = k - 0.10
      
    
    # plotting parameters
    
    panel.set_xlabel('Position index \n(Tile number + Base (bp))', labelpad = 25)
    panel.set_ylabel('Deviation from average quality', labelpad = 25)
    
    
    # add module name
    
    panel.text(0.50, 1.10, "Per tile sequence quality", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_per_sequence_quality_scores(fastqc_data, panel):
      
    '''
    Per sequence quality scores
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    
    
    # load data
    m = 'Per sequence quality scores'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
        
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'
    
    max_xlims = []    
    for s in flags.index:
        
        # subset data
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])

        # plot
        panel.plot(_['#Quality'], (100. * _['Count']) / sum(_['Count']),
                   color = flag_to_color[flag], alpha = 0.50)

        # label samples with warn and fail flags
        if (flag == 'warn') or (flag == 'fail'):
            x = list(_['#Quality'])[-1] + 1
            y = (100. * list(_['Count'])[-1]) / sum(_['Count'])
            panel.text(x - 0.50, y, file_id, color = flag_to_color[flag], fontsize = 12,
                    horizontalalignment = 'left', verticalalignment = 'center')

        # get maximum xlim value
        max_xlims.append(max(_['#Quality']))
    
    # labels and decorations
    panel.set_xlim(0, max(max_xlims))
    panel.set_ylim(0, 100)
    panel.set_xlabel('Mean sequence quality (Phred Score)', labelpad = 25)
    panel.set_ylabel('Percentage of sequences', labelpad = 25)
    
    
    # add module name
    
    panel.text(0.50, 1.10, "Per sequence quality scores", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_per_base_sequence_content(fastqc_data, panel_a, panel_b):

    '''
    Per base sequence content
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Per base sequence content'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()

    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    base_to_color = {}
    base_to_color['T'] = 'red'
    base_to_color['C'] = 'blue'
    base_to_color['A'] = 'green'
    base_to_color['G'] = 'black'
    
    df_long = pd.DataFrame()
    for s in flags.index:
        
        # subset data and re-shape
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        _ = _[list(_.columns)[:-1]]
        _ = _.set_index('#Base').transpose().reset_index()
        _['file_id'] = s
        df_long = pd.concat([df_long, _])
  
    
    # plot
    cols = list(df_long.columns)[:-1]       
    spacer = 5
    bases = list(df_long['index'])
    df_long['index'] = 0      
    xticklabels = [i for i in np.arange(spacer, list(df_long.columns)[-2] + spacer, spacer)]
    file_ids = list(df_long['file_id'])
    yticklabels = [file_ids[i] for i in range(0, len(df_long), 4)]
    g = sns.heatmap(df_long[cols], ax = panel_a, square = True, vmin = 0, vmax = 100,
                    linewidths = 0.25, yticklabels = yticklabels, xticklabels = xticklabels,
                    cbar_ax = panel_b, robust = True)
    
    # labels and decorations
    panel_a.set_xlabel('Position in read (bp)', labelpad = 25)
    g.set_xticklabels(g.get_xticklabels(), rotation = 0)
    panel_a.set_xticks(panel_a.get_xticks()[(spacer)::spacer])
    panel_a.set_yticks([i + 1.5 for i in panel_a.get_yticks()[::4]])
    
    # label each base with a different color
    for i, b in zip(range(len(df_long)), bases):
        panel_a.add_patch(patches.Rectangle((0, len(df_long) - i - 1), 1, 1, 
                                          facecolor = base_to_color[b], alpha = 0.75,
                                            linewidth = 0))
        
    # add line to separate samples
    for i in range(len(df_long)):
        
        if i % 4 == 0:
               
            panel_a.add_patch(patches.Rectangle((0, i), len(list(df_long.columns)[1:-1]) + 1, 4,
                                              alpha = 0.75, fill = False, linewidth = 2,
                                             edgecolor = 'gray'))

            
    # add base names
    h = 0
    for k in sorted(base_to_color.keys()):
        
        panel_b.text(0.25, 3 - h, k, color = base_to_color[k], transform = panel_b.transAxes)
        h += 0.15
        

    # complement barscale
    panel_b.text(0.25, 1.25, '% of base per base', transform = panel_b.transAxes) 
            
        
    # add module name
    
    panel_a.text(0.50, 1.10, "Per base sequence content", transform = panel_a.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_per_sequence_gc_content(fastqc_data, panel):


    '''
    Per sequence GC content
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Per sequence GC content'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    
    for s in flags.index:
        
        # subset data and plot
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        panel.plot(_['#GC Content'], (100. * _['Count']) / sum(_['Count']),
                   color = flag_to_color[flag], alpha = 0.50)
        
        # label samples with warn and fail flags
        if (flag == 'warn') or (flag == 'fail'):
            i += 0.50 
            panel.text(101, i, file_id, color = flag_to_color[flag], fontsize = 12,
                    horizontalalignment = 'left', verticalalignment = 'center')

    
    # labels and decorations

    panel.set_xlim(0, 100)
    panel.set_ylim(0, )
    panel.set_xlabel('GC content', labelpad = 25)
    panel.set_ylabel('Percentage of sequences', labelpad = 25)
    
    
    # add module name
    
    panel.text(0.50, 1.10, "Per sequence GC content", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_per_base_n_content(fastqc_data, panel):

    '''
    Per base N content
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Per base N content'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    
    for s in flags.index:
        
        # subset data and plot
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        panel.plot(_['#Base'], _['N-Count'], color = flag_to_color[flag], alpha = 0.50)
        
        # label samples with warn and fail flags
        if (flag == 'warn') or (flag == 'fail'):
            i += 0.50 
            panel.text(101, i, file_id, color = flag_to_color[flag], fontsize = 12,
                    horizontalalignment = 'left', verticalalignment = 'center')
            
    
    # labels and decorations

    panel.set_xlim(0, )
    panel.set_ylim(0, )
    panel.set_xlabel('Position in read (bp)', labelpad = 25)
    panel.set_ylabel('Percentage of N bases', labelpad = 25)
    
    
    # add module name
    
    panel.text(0.50, 1.10, "Per base N content", transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_sequence_length_distribution(fastqc_data, panel):

    '''
    Sequence length distribution
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Sequence Length Distribution'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    x_mins = []
    x_maxs = []
    for s in flags.index:
        
        # subset data and plot
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        x_min = min(_['#Length'])
        x_max = max(_['#Length'])
        k = pd.DataFrame([[x_min - 1, x_max + 1], [0, 0], [s, s]]).transpose()
        k.columns = _.columns
        _ = pd.concat([_, k])
        _ = _.sort_values(['#Length'])
        panel.plot(_['#Length'], (100. * _['Count']) / sum(_['Count']),
                   color = flag_to_color[flag], alpha = 0.50)
        x_mins.append(x_min)
        x_maxs.append(x_max)
                
        # label samples with warn and fail flags
        if (flag == 'warn') or (flag == 'fail'):
            i += 0.50 
            panel.text(101, i, file_id, color = flag_to_color[flag], fontsize = 12,
                    horizontalalignment = 'left', verticalalignment = 'center')
                        
    
    # labels and decorations

    panel.set_xlim(min(x_mins) - 2.5, max(x_maxs) + 2.5)
    panel.set_ylim(0, )
    panel.set_xlabel('Read length (bp)', labelpad = 25)
    panel.set_ylabel('Percentage of reads', labelpad = 25)
    

    # add module name
    
    panel.text(0.50, 1.10, m, transform = panel.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)


def plot_sequence_duplication_levels(fastqc_data, panel_a, panel_b, panel_c):

    '''
    Sequence Duplication Levels
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Sequence Duplication Levels'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
       
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    # plot percentage of sequences remaining if deduplicated
    dedups = df[['file_id', 'dedup_perc']].drop_duplicates()
    sns.barplot(x = 'file_id', y = 'dedup_perc', data = df, ax = panel_a,
                orient = 'v', palette = sns.color_palette("Paired", len(df) / 2))
    panel_a.set_xticklabels(dedups.file_id, rotation = 90)
    panel_a.set_ylabel('% of reads if deduplicated', labelpad = 25)
    panel_a.set_xlabel('')
    panel_a.set_ylim(0, 100)
    
    # boxplot
    sns.boxplot(y = 'dedup_perc', data = df, ax = panel_b, color = 'lightgray', width = 0.50)
    panel_b.set_ylim(0, 100)
    panel_b.axes.yaxis.set_ticklabels([])
    panel_b.set_ylabel('')
    
    
    for s in flags.index:
        
        # subset data and plot
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        ind = np.arange(len(_))
        panel_c.plot(ind, _['Percentage of total'], color = flag_to_color[flag])
        panel_c.plot(ind, -_['Percentage of deduplicated'], color = flag_to_color[flag],
                    linestyle = ':')
    
    panel_c.set_xticks(ind)
    panel_c.set_xticklabels(_['#Duplication Level'])
    panel_c.set_ylim(-100, 100)
    panel_c.set_ylabel('% of sequences \nTotal (+) or deduplicated (-)', labelpad = 25)
    panel_c.set_xlabel('Sequence dupliction level', labelpad = 25)
    
    # add module name
    panel_c.text(0.50, 1.10, m, transform = panel_c.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)    


def plot_overrepresented_sequences(fastqc_data, panel_a, panel_b):

    '''
    Overrepresented sequences
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Overrepresented sequences'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # aggregate based on the possible source
    cols = ['Possible Source', 'file_id', 'Percentage']
    df_grouped = df[cols].groupby(cols[:-1]).sum().reset_index()

    # convert to matrix
    k = df_grouped.pivot(index = 'Possible Source', columns = 'file_id', values = 'Percentage')
    
    # heatmap
    sns.heatmap(k, square = True, robust = True, ax = panel_a, cbar_ax = panel_b)
    
    # labels and decorations
    panel_a.set_xlabel('')    
    plt.setp(panel_a.xaxis.get_majorticklabels(), rotation = 90 )
    plt.setp(panel_a.yaxis.get_majorticklabels(), rotation = 0 )

    # add module name
    panel_a.text(0.50, 1.10, m, transform = panel_a.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)    


def plot_adapter_content(fastqc_data, panel_a, panel_b):

    '''
    Adapter content
    '''

    # load python packages    
    
    import pandas as pd
    import seaborn as sns
    from matplotlib.colors import ListedColormap
    import matplotlib.patches as patches
   
    
    # load data
    m = 'Adapter Content'
    df = fastqc_data[m].copy()   
    flags = fastqc_data['Basic statistics'].copy()
    
    
    # plotting parameters
    
    flag_to_color = {}
    flag_to_color['1'] = 'green'
    flag_to_color['0'] = 'orange'
    flag_to_color['-1'] = 'red'

    adapter_to_color = {}
    adapter_to_color['Illumina Universal Adapter'] = 'red'
    adapter_to_color["Illumina Small RNA 3' Adapter"] = 'blue'
    adapter_to_color["Illumina Small RNA 5' Adapter"] = 'green'
    adapter_to_color['Nextera Transposase Sequence'] = 'black'
    adapter_to_color['SOLID Small RNA Adapter'] = 'pink'
    
    
    df_long = pd.DataFrame()
    for s in flags.index:
        
        # subset data and re-shape
        _ = df[df['file_id'] == s]
        flag = str(list(flags[flags.index == s][m])[0])
        _ = _[list(_.columns)[:-1]]
        _ = _.set_index('#Position').transpose().reset_index()
        _['file_id'] = s
        df_long = pd.concat([df_long, _])
      
    # plot
    cols = list(df_long.columns)[:-1]       
    spacer = 5
    bases = list(df_long['index'])
    df_long['index'] = 0      
    xticklabels = [i for i in np.arange(spacer, list(df_long.columns)[-2] + spacer, spacer)]
    file_ids = list(df_long['file_id'])
    yticklabels = [file_ids[i] for i in range(0, len(df_long), 4)]
    g = sns.heatmap(df_long[cols], ax = panel_a, square = True, vmin = 0, robust = True,
                    linewidths = 0.25, yticklabels = yticklabels, xticklabels = xticklabels,
                    cbar_ax = panel_b)
    
    # labels and decorations
    panel_a.set_xlabel('Position in read (bp)', labelpad = 25)
    g.set_xticklabels(g.get_xticklabels(), rotation = 0)
    panel_a.set_xticks(panel_a.get_xticks()[(spacer)::spacer])
    panel_a.set_yticks([i + 1.5 for i in panel_a.get_yticks()[::4]])
    
    # label each base with a different color
    for i, b in zip(range(len(df_long)), bases):
        panel_a.add_patch(patches.Rectangle((0, len(df_long) - i - 1), 1, 1, 
                                          facecolor = adapter_to_color[b], alpha = 0.75,
                                            linewidth = 0))
        
    # add line to separate samples
    for i in range(len(df_long)):
        
        if i % 5 == 0:
               
            panel_a.add_patch(patches.Rectangle((0, i), len(list(df_long.columns)[1:-1]) + 1, 5,
                                              alpha = 0.75, fill = False, linewidth = 2,
                                             edgecolor = 'gray'))
            
            
    # add module name
    
    panel_a.text(0.50, 1.10, m, transform = panel_a.transAxes,
               horizontalalignment = 'center', weight = 'bold', fontsize = 24)
    
    
    # add adapter names
    h = 0
    for k in sorted(adapter_to_color.keys()):
        
        panel_b.text(0.25, 3 - h, k, color = adapter_to_color[k], transform = panel_b.transAxes)
        h += 0.15
        

    # complement barscale
    panel_b.text(0.25, 1.25, '% of adapter per base', transform = panel_b.transAxes)       




#==================================================================================================
# combine functions
#==================================================================================================

def fastqsee(data_type, step, samples):
    

    fastqc_data = parse_data_from_fastqc_report(data_type, step, samples)  
    
    
    # plot backbone   
    
    plt.close('all')
    f = plt.figure(figsize = (20, 150))
    f.subplots_adjust(wspace = 1, hspace = 1)  
    nrows = 175
    ncols = 100
    panel_1 = plt.subplot2grid((nrows, ncols), (0, 0), rowspan = 10, colspan = 100)
    panel_2a = plt.subplot2grid((nrows, ncols), (15, 0), rowspan = 8, colspan = 40)
    panel_2b = plt.subplot2grid((nrows, ncols), (23, 0), rowspan = 2, colspan = 40)
    panel_3 = plt.subplot2grid((nrows, ncols), (15, 60), rowspan = 10, colspan = 40)
    panel_4 = plt.subplot2grid((nrows, ncols), (30, 0), rowspan = 10, colspan = 40)
    panel_5 = plt.subplot2grid((nrows, ncols), (30, 60), rowspan = 10, colspan = 40)
    panel_6a = plt.subplot2grid((nrows, ncols), (35, 0), rowspan = 20, colspan = 99)
    panel_6b = plt.subplot2grid((nrows, ncols), (45, 99), rowspan = 5, colspan = 1)
    panel_7 = plt.subplot2grid((nrows, ncols), (65, 0), rowspan = 10, colspan = 40)
    panel_8 = plt.subplot2grid((nrows, ncols), (65, 60), rowspan = 10, colspan = 40)
    panel_9 = plt.subplot2grid((nrows, ncols), (85, 0), rowspan = 10, colspan = 40)
    panel_10a = plt.subplot2grid((nrows, ncols), (120, 0), rowspan = 5, colspan = 90)
    panel_10b = plt.subplot2grid((nrows, ncols), (120, 90), rowspan = 5, colspan = 10)
    panel_10c = plt.subplot2grid((nrows, ncols), (105, 0), rowspan = 10, colspan = 100)
    if len(fastqc_data['Overrepresented sequences']) > 0:
        panel_11a = plt.subplot2grid((nrows, ncols), (130, 0), rowspan = 20, colspan = 49)
        panel_11b = plt.subplot2grid((nrows, ncols), (140, 49), rowspan = 5, colspan = 1)
    panel_12a = plt.subplot2grid((nrows, ncols), (155, 0), rowspan = 20, colspan = 99)
    panel_12b = plt.subplot2grid((nrows, ncols), (165, 99), rowspan = 5, colspan = 1)

    
    # Plot modules
    
    plot_basic_statistics(fastqc_data, panel_1)
    plot_total_number_of_sequences(fastqc_data, panel_2a, panel_2b)
    plot_per_base_sequence_quality(fastqc_data, panel_3)
    plot_per_tile_sequence_quality(fastqc_data, panel_4)
    plot_per_sequence_quality_scores(fastqc_data, panel_5)
    plot_per_base_sequence_content(fastqc_data, panel_6a, panel_6b)
    plot_per_sequence_gc_content(fastqc_data, panel_7)
    plot_per_base_n_content(fastqc_data, panel_8)
    plot_sequence_length_distribution(fastqc_data, panel_9)
    plot_sequence_duplication_levels(fastqc_data, panel_10a, panel_10b, panel_10c)    
    if len(fastqc_data['Overrepresented sequences']) > 0:
        plot_overrepresented_sequences(fastqc_data, panel_11a, panel_11b)
    plot_adapter_content(fastqc_data, panel_12a, panel_12b)


if __name__ == "__fastqsee__":
    fastqsee(data_type, step, samples)
