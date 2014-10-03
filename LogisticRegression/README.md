
# Low Birth Weight data set - Logistic Regression and Visualization

My initial goal was to implement Logistic Regression, but along the way I also did quite a bit of visual exploration and played around with L1 and L2 penalties when implementing Logistic Regression. 
I also looked a bit at PCA and feature selection, while plotting a mix of different aspects such
as coefficients and distributions of the data.


    %matplotlib inline
    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as pyplot
    from matplotlib import cm
    import seaborn as sns
    from pandas.tools.plotting import andrews_curves
    from mpl_toolkits.mplot3d import Axes3D
    from sklearn import linear_model
    from sklearn.linear_model import LogisticRegression
    from sklearn.metrics import accuracy_score
    from sklearn.cross_validation import train_test_split
    

    # read low birth weight dataset
    lbw = pd.read_table('/Users/Gabi/DataScience/lowbwt.txt', header= None, 
                        names= ['id','low','age','lwt','race','smoke','ptl','ht','ui','ftv','bwt'] )

A quick look at what the data looks like:


    lbw.head()




<div style="max-height:1000px;max-width:1500px;overflow:auto;">
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>low</th>
      <th>age</th>
      <th>lwt</th>
      <th>race</th>
      <th>smoke</th>
      <th>ptl</th>
      <th>ht</th>
      <th>ui</th>
      <th>ftv</th>
      <th>bwt</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td> 85</td>
      <td> 0</td>
      <td> 19</td>
      <td> 182</td>
      <td> 2</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 1</td>
      <td> 0</td>
      <td> 2523</td>
    </tr>
    <tr>
      <th>1</th>
      <td> 86</td>
      <td> 0</td>
      <td> 33</td>
      <td> 155</td>
      <td> 3</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 3</td>
      <td> 2551</td>
    </tr>
    <tr>
      <th>2</th>
      <td> 87</td>
      <td> 0</td>
      <td> 20</td>
      <td> 105</td>
      <td> 1</td>
      <td> 1</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 1</td>
      <td> 2557</td>
    </tr>
    <tr>
      <th>3</th>
      <td> 88</td>
      <td> 0</td>
      <td> 21</td>
      <td> 108</td>
      <td> 1</td>
      <td> 1</td>
      <td> 0</td>
      <td> 0</td>
      <td> 1</td>
      <td> 2</td>
      <td> 2594</td>
    </tr>
    <tr>
      <th>4</th>
      <td> 89</td>
      <td> 0</td>
      <td> 18</td>
      <td> 107</td>
      <td> 1</td>
      <td> 1</td>
      <td> 0</td>
      <td> 0</td>
      <td> 1</td>
      <td> 0</td>
      <td> 2600</td>
    </tr>
  </tbody>
</table>
</div>




    label = lbw[['low']]; #label to predict
    features = lbw.loc[:, 'age':'bwt']; #ignore id

I split the data for training and testing using train-test-split from sklearn:
66% is allocated to training and 34% for testing:


    # split data for training and testing: training = 66% and testing = 34%
    train, test, label_train, label_test =  train_test_split(features, label , test_size = .34, random_state =42)

    # turn train into dataframe (train_test_split returns array with no column names)
    train = pd.DataFrame(train, columns = ['age','lwt','race','smoke','ptl','ht','ui','ftv','bwt'] )
    # set x
    x = train
    # set label - need to ravel in order to flatten to 1d array
    y = np.ravel(label_train)
    print("x:\n",x.head())

    x:
        age  lwt  race  smoke  ptl  ht  ui  ftv   bwt
    0   29  135     1      0    0   0   0    1  3651
    1   30  110     3      0    0   0   0    0  3475
    2   26  154     3      0    1   1   0    1  2442
    3   19  138     1      1    0   0   0    2  2977
    4   16  170     2      0    0   0   0    4  3860

    # create training set with training data and label
    training = train.copy()
    training['low']=label_train
    training.head()




<div style="max-height:1000px;max-width:1500px;overflow:auto;">
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>age</th>
      <th>lwt</th>
      <th>race</th>
      <th>smoke</th>
      <th>ptl</th>
      <th>ht</th>
      <th>ui</th>
      <th>ftv</th>
      <th>bwt</th>
      <th>low</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td> 29</td>
      <td> 135</td>
      <td> 1</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 1</td>
      <td> 3651</td>
      <td> 0</td>
    </tr>
    <tr>
      <th>1</th>
      <td> 30</td>
      <td> 110</td>
      <td> 3</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 3475</td>
      <td> 0</td>
    </tr>
    <tr>
      <th>2</th>
      <td> 26</td>
      <td> 154</td>
      <td> 3</td>
      <td> 0</td>
      <td> 1</td>
      <td> 1</td>
      <td> 0</td>
      <td> 1</td>
      <td> 2442</td>
      <td> 1</td>
    </tr>
    <tr>
      <th>3</th>
      <td> 19</td>
      <td> 138</td>
      <td> 1</td>
      <td> 1</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 2</td>
      <td> 2977</td>
      <td> 0</td>
    </tr>
    <tr>
      <th>4</th>
      <td> 16</td>
      <td> 170</td>
      <td> 2</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 0</td>
      <td> 4</td>
      <td> 3860</td>
      <td> 0</td>
    </tr>
  </tbody>
</table>
</div>




    # turn test into dataframe (train_test_split returns array with no column names)
    test = pd.DataFrame(test, columns = ['age','lwt','race','smoke','ptl','ht','ui','ftv','bwt'] )
    # set x
    x_test = test
    # set label - need to ravel in order to flatten to 1d array
    y_test = np.ravel(label_test)
    print("x_test:\n",x_test.head())

    x_test:
        age  lwt  race  smoke  ptl  ht  ui  ftv   bwt
    0   28   95     1      1    0   0   0    2  2466
    1   18  148     3      0    0   0   0    0  2282
    2   20  120     3      0    0   0   1    0  2807
    3   18  100     1      1    0   0   0    0  2769
    4   28  250     3      1    0   0   0    6  3303


### Visually Exploring the data
In order to explore the data, I used scatter-matrix from pandas to show the
pairwise correlations between different variables. When doing so, I noticed there
are way too many features in the dataset.


    from pandas.tools.plotting import scatter_matrix
    axeslist=scatter_matrix(x, alpha=0.5, figsize=(14, 12), diagonal="kde", density_kwds={'color':'red'}, 
                            c = training.low, cmap = cm.jet_r)
    for ax in axeslist.flatten():
        ax.grid(True)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/initial_corrmatrix.png)

Using the training set as input with all the features doesn't add much value, so
I reduced the input to another version of the training set with only age, lwt
(weight in lbs of mother at last menstrual period), and bwt.

*LWT and AGE:* the points seem to be mixed: many women between 15 and 35 are in
the 100-200 lbs range with mixed outcomes of baby birth weights, and there seem
to be a few outliers where weight is over 200 lbs.

*LWT and BWT* (birth weight in grams - where bwt <2500g  is considered low):
Since the data set contains fewer low birth weight samples it seems like there
are more normal babies born to mothers where the weight in lbs at last menstrual
period ranges from high to low. If we look at birth weight <2500g in blue, it
looks like there are more women below 130 lbs.


    # reduced x input to fewer features
    x2 = x[['age','bwt','lwt']]
    axeslist=pd.scatter_matrix(x2, alpha=0.9, figsize=(8,8), diagonal="kde", density_kwds={'color':'red'}, 
                            c = training.low, marker ='o', cmap = cm.jet_r)
    for ax in axeslist.flatten():
        ax.grid(True, axis = 'both', which='both',  linestyle='--', linewidth=1, c='skyblue')
        x_ticks = ax.get_xticks()
        x_labels = ax.get_xlabel()
        ax.set_xticklabels(x_ticks, rotation=0)
        ax.set_xlabel(x_labels, rotation = 0, labelpad = 20)
        y_labels = ax.get_ylabel()
        ax.set_ylabel(y_labels, rotation = 0, labelpad=20)



![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/modifiedMatrix.png)


### Further exploring features in the data
Next, I created a few smaller dataframes to further explore the different
features in the training data.
#### Mother's weight at last period and birth weight of baby
The first scatter plot shows mother's weight at last period and birth weight of
baby: The red points represent normal weight babies and the blue points
correspond to low birth weight babies (<2500g). There seems to be a cluster of
low birth weight babies where the weight of the mother is below 125lbs but
there is no clear trend.


    # dataframe for lwt & bwt (weight at last period & birth weight of baby)
    x_lwtbwt = x.loc[:, ['lwt','bwt']]
    # Scatter plot of weight at last period and birth weight of baby (training set)
    fig = pyplot.figure()
    ax = fig.add_subplot(1,1,1)
    ax.scatter(x_lwtbwt.ix[y==0, 0], x_lwtbwt.ix[y==0, 1], c= 'r', edgecolors = 'r', label = 'birth weight >2500g', s= 45) # lwt 
    ax.scatter(x_lwtbwt.ix[y==1, 0], x_lwtbwt.ix[y==1, 1], c= 'b', edgecolors = 'b', label = 'birth weight <2500g', s= 45) # bwt
    pyplot.xlabel(x_lwtbwt.columns[0] + " (lbs)")
    pyplot.ylabel(x_lwtbwt.columns[1] + " (g)" , rotation = 0, labelpad=20 )
    ax.grid(which='major')
    ax.legend(loc = 4, fontsize='small', scatterpoints=2, fancybox = True)
    ax.set_title('Weight at last menstrual period and birth weight in grams', fontsize = 'large')
    pyplot.show(fig)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/simple_scatter.png)

#### Race Birth weight race
This next subset of the training data shows race and baby birth weight. Here we
can see that there are fewer samples of black women and more white women. Also,
women labeled as 'other' race seem to have about half low birth weight babies
and half normal weight.

    # dataframe for race & bwt
    x_racebwt = x.loc[:, ['race','bwt']]
    
    # change tick labels for race
    x_TicksNew = [item for item in ['white','black','other']]
    
    # plot points from training set of bwt and race
    fig1 = pyplot.figure()
    ax = fig1.add_subplot(1,1,1)
    ax.scatter(x_racebwt.ix[y==0, 0], x_racebwt.ix[y==0, 1], c= 'g', edgecolors = 'g', label = 'birth weight >2500g', s= 45, marker ='^') # race
    ax.scatter(x_racebwt.ix[y==1, 0], x_racebwt.ix[y==1, 1], c= 'y', edgecolors = 'y', label = 'birth weight <2500g', s= 45, marker ='^') # bwt
    pyplot.xlabel(x_racebwt.columns[0], labelpad = 10) #labelpad: add space btw points and label
    pyplot.ylabel(x_racebwt.columns[1], rotation = 0, labelpad = 20)
    ax.grid(which='major')
    x_plot_labels = [item.get_text() for item in ax.get_xticklabels()]
    x_plot_labels[1] = 'White'
    x_plot_labels[2]='Black'
    x_plot_labels[3]='Other'
    ax.set_xticklabels(x_TicksNew)
    ax.set_xticks([1,2,3])
    ax.legend(loc = 3, fontsize='small', scatterpoints=2, fancybox = True)
    ax.set_title('Birth weight and Race', fontsize = 'large')
    ax.grid(True)
    pyplot.show(fig1)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/race_plot1.png)

#### Race, age and birth weight
While noticing that there are fewer samples of black women and more white women,
I wanted to drill in and see the actual percentages in the data and represent
this in a bar graph. In doing so, I noted that less than 15% of the data
contained black women.


    # create a second version of dataframe where we replace race numbers 1,2 3 with types and add age column
    x_racebwt_2 =  x.loc[:, ['race','age','bwt']].replace([1,2,3],['white','black','other'])
    #x_racebwt.replace([1,2,3],['white','black','other'])
    x_racebwt_2.head()

<div style="max-height:1000px;max-width:1500px;overflow:auto;">
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>race</th>
      <th>age</th>
      <th>bwt</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td> white</td>
      <td> 29</td>
      <td> 3651</td>
    </tr>
    <tr>
      <th>1</th>
      <td> other</td>
      <td> 30</td>
      <td> 3475</td>
    </tr>
    <tr>
      <th>2</th>
      <td> other</td>
      <td> 26</td>
      <td> 2442</td>
    </tr>
    <tr>
      <th>3</th>
      <td> white</td>
      <td> 19</td>
      <td> 2977</td>
    </tr>
    <tr>
      <th>4</th>
      <td> black</td>
      <td> 16</td>
      <td> 3860</td>
    </tr>
  </tbody>
</table>
</div>


    # check that correct replacements were made
    print("Check replacements made, first 4 should be false\n", x_racebwt_2.race.isin(["black"]).head(), 
          "\n\n",x_racebwt_2.loc[x_racebwt_2.race=="white"].head())

    Check replacements made, first 4 should be false
     0    False
    1    False
    2    False
    3    False
    4     True
    Name: race, dtype: bool 
    
         race  age   bwt
    0  white   29  3651
    3  white   19  2977
    5  white   36  2836
    6  white   20  3940
    7  white   24  4593

    # fewest black samples:
    total_count = x_racebwt_2.race.value_counts().sum()
    count_races = pd.DataFrame(x_racebwt_2.race.value_counts(), 
                               columns=['race_count'])
    print("Total count:", total_count, "\n")
    print(count_races.head())

    Total count: 124 
    
           *race_count*
    white          67
    other          43
    black          14



    # take a look at percents of each race in training set
    count_races['percents']= count_races/total_count
    print(count_races.head())
    ax = count_races.race_count.plot(kind = 'barh', cmap = cm.cool);
    ax.set_title("Count of each race in training set")
    # annotate plot with percentages
    for i, var in enumerate(count_races.percents):
        ax.annotate(np.str(np.round(count_races.percents[i],4)*100)+"%", (5,i))

           race_count  percents
    white          67  0.540323
    other          43  0.346774
    black          14  0.112903


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/raceBar.png)

When plotting each race separately, the minimum birth weight is the lowest for
'other' race women seemingly close to 700g while the maximum is close to
5000g for white women. Also, the range of birth weight for black women is
between 1928g and 3860g.


    # plot lines of the diff birth weights by race 
    cols = ['red','blue','magenta']
    x_racebwt_v2 = x_racebwt.replace([1,2,3],['white','black','other'])
    fig, axes = pyplot.subplots(nrows=1, ncols=3, figsize=(12,4), sharey=True)
    for i, var in enumerate(['white','black','other']):
        x_racebwt_v2.loc[x_racebwt_v2.race==var].plot(ax = axes[i], title = var + " women" , color=cols[i], legend = '')
    axes[0].set_ylabel('bwt', rotation = 0, labelpad = 20)
    fig.subplots_adjust(hspace=0.25, wspace=0.25)
    pyplot.show(fig)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/compare_race1.png)

    # find min and max for black women
    print("min", min(x_racebwt_v2.bwt.loc[x_racebwt_v2.race=="black"]))
    print("max", max(x_racebwt_v2.bwt.loc[x_racebwt_v2.race=="black"]))

    min 1928
    max 3860

#### Smoke and birth weight
In the next visualization, it looks like the training set has less women who
smoke and also more women who smoke and have low weight babies.


    # dataframe for smoke & bwt
    x_smokebwt = x.loc[:, ['smoke','bwt']]
    # plot points from training set of smoke & bwt
    fig2 = pyplot.figure()
    ax = fig2.add_subplot(1,1,1)
    ax.scatter(x_smokebwt.ix[y==0, 0], x_smokebwt.ix[y==0, 1], c= 'blue', edgecolors = 'blue', label = 'birth weight >2500g', s= 45) # smoke 
    ax.scatter(x_smokebwt.ix[y==1, 0], x_smokebwt.ix[y==1, 1], c= 'red', edgecolors = 'red', label ='birth weight <2500g', s= 45) # bwt
    #pyplot.xlim(x_agesmoke[['age']].min() - 2  , x_agesmoke[['age']].max() + 2 ) # set limits of x axis (age)
    #pyplot.ylim(x_agesmoke[['smoke']].min() - 2, x_agesmoke[['smoke']].max() + 2 ) # set limits of y axis (race)
    pyplot.xlabel(x_smokebwt.columns[0])
    pyplot.ylabel(x_smokebwt.columns[1], rotation=0, labelpad=20) #rotate label and add space
    ax.legend(loc = "best", fontsize='small', scatterpoints=2, fancybox = True)
    ax.set_title('Birth weight and Smoke', fontsize = 'large')
    
    
    # change tick labels for smoke
    x_TickNew = [item for item in ['No','Yes']]
    # get tick labels
    xplot_labels = [item.get_text() for item in ax.get_xticklabels()]
    # change to only 2 labels - No and Yes
    xplot_labels[0]='No'
    xplot_labels[1]='Yes'
    ax.set_xticklabels(x_TickNew)
    # need to also change the ticks for x-axis
    ax.set_xticks([0,1])
    # show only major axes 
    ax.grid(which='major')
    ax.grid(True)
    pyplot.show(fig2)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/smoke_yesno.png)

#### History of Premature Birth and birth weight
The data has fewest samples of women who have had 2 premature births and the
most samples of women with no previous history of premature births.


    # dataframe for bwt & ptl (history of premature birth: 0 or 1 or more)
    x_ptlbwt = x.loc[:, ['ptl','bwt']]
    # plot points from training set of bwt and ptl
    fig3 = pyplot.figure()
    ax = fig3.add_subplot(1,1,1)
    ax.scatter(x_ptlbwt.ix[y==0, 0], x_ptlbwt.ix[y==0, 1], c= 'b', edgecolors = 'b', label = 'birth weight >2500g', s= 45) # ptl 
    ax.scatter(x_ptlbwt.ix[y==1, 0], x_ptlbwt.ix[y==1, 1], c= 'y', edgecolors = 'y', label = 'birth weight <2500g', s= 45) # bwt
    #pyplot.xlim(x_ageptl[['age']].min() - 2  , x_ageptl[['age']].max() + 2 ) # set limits of x axis (age)
    #pyplot.ylim(x_ageptl[['ptl']].min() - 2, x_ageptl[['ptl']].max() + 2 ) # set limits of y axis (race)
    pyplot.xlabel(x_ptlbwt.columns[0])
    pyplot.ylabel(x_smokebwt.columns[1], rotation=0, labelpad=20) #rotate label and add space
    ax.legend(loc = 'best', fontsize='small', scatterpoints=2, fancybox = True)
    ax.set_title('Birth weight and History of premature birth', fontsize = 'large')
    
    # change tick labels for number of premature births
    x_TickNew = [item for item in ['0','1','2']]
    # get tick labels
    xplot_labels = [item.get_text() for item in ax.get_xticklabels()]
    # change to only 2 labels - No and Yes
    xplot_labels[0]='0'
    xplot_labels[1]='1'
    xplot_labels[2]='2'
    ax.set_xticklabels(x_TickNew)
    # need to also change the ticks for x-axis
    ax.set_xticks([0,1,2])
    
    
    pyplot.show(fig3)


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/prem.png)


#### Frequency of age and birth weight


    x_racebwt_2.plot(kind='line', subplots=True, color='r')
    array([<matplotlib.axes._subplots.AxesSubplot object at 0x109c83f10>,
           <matplotlib.axes._subplots.AxesSubplot object at 0x1098d90d0>], dtype=object)


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/freq.png)


#### Interested in seeing subset of women who smoke and give birth to low weight babies


    # subset smoking ==1 and low birth weight ==1
    smoking_low = training[training.low.isin([1]) & training.smoke.isin([1])]
    print("Women who smoke and are 'other' race - with low birth weight babies:\n", smoking_low[smoking_low.race ==3])
    print()
    print("Count of women who smoke and are white - with low birth weight:", np.count_nonzero(smoking_low.race[smoking_low.race ==1]))
    print()
    print("Women who smoke and are 'black - with low birth weight babies:\n", smoking_low[smoking_low.race ==2])

    Women who smoke and are 'other' race - with low birth weight babies:
          age  lwt  race  smoke  ptl  ht  ui  ftv   bwt  low
    47    14  101     3      1    1   0   0    0  2466    1
    60    23   94     3      1    0   0   0    0  2495    1
    108   28  120     3      1    1   0   1    0   709    1
    
    Count of women who smoke and are white - with low birth weight: 15
    
    Women who smoke and are 'black - with low birth weight babies:
         age  lwt  race  smoke  ptl  ht  ui  ftv   bwt  low
    11   24  105     2      1    0   0   0    0  2381    1
    65   23  187     2      1    0   0   0    1  2367    1
    76   20  122     2      1    0   0   0    0  2381    1


#### Density Estimations of Birth Weight by Race
In looking at the different populations in the training sample, white women
represent the majority while black women are the least.

Next, I wanted to explore the different distributions of birth weight by race,
so I used the kernel density estimate to plot these. When I initially plotted
these, all densities kind of looked similar, but when putting all variables on
the same x and y axis, I noticed that white women had similar distributions to
other women with more variance in the birth weights while black women had the
narrowest distribution of all.


    # density plot of birth weight by race
    fig1, axes = pyplot.subplots(nrows=1, ncols=3, figsize=(14,4))
    for i, var in enumerate(['white','black','other']):
        x_racebwt_v2.loc[x_racebwt_v2.race == var].plot(kind = 'kde', ax = axes[i], color = cols[i], title = var, lw =2)
        axes[i].set_ylabel('')
    axes[0].set_ylabel('density', rotation = 0, labelpad = 20)
    fig1.subplots_adjust(hspace=0.25, wspace=0.25)
    pyplot.tight_layout()
    pyplot.show()


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/women_density.png)

    # density plot of birth weight by race - share x and y axes
    fig2, axes = pyplot.subplots(nrows=1, ncols=3, figsize=(14,4), sharex=True, sharey=True)
    for i, var in enumerate(['white','black','other']):
        x_racebwt_v2.loc[x_racebwt_v2.race == var].plot(kind = 'kde', ax = axes[i], color = cols[i], title = var, lw =2)
        axes[i].set_ylabel('')
    axes[0].set_ylabel('density', rotation = 0, labelpad = 20)
    fig2.subplots_adjust(hspace=0.25, wspace=0.25)
    pyplot.tight_layout()
    pyplot.show()

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/women_density_2.png)


### Seaborn Package KDE plot function
I also explored the seaborn package and used the KDE plot function to look at
the density estimate of race and birth weight (1st) as well as age and
birth weight (2nd).

The 1st kde plot shows that the lowest points come from the white and other
race women samples, and that the birth weight varies less for black women.

The 2nd plot shows that birth weight <1000g comes from women around 27-30
years old, and that there arent any low births for women at the maximum age in
the training set. The maximum age for women is 45 and there are no low birth
weight babies.


    # This plot uses the seaborn package to plot a density estimate of birthweight and race and birthweight and age
    # add a horizontal line at 2500 to separate low birth weight in both plots
    
    
    # seaborn kde plot of race and birth weight
    fig, (ax1,ax2) = pyplot.subplots(nrows=1, ncols = 2, sharey = True, figsize = (12,6))
    sns.kdeplot(x_racebwt.race, x_racebwt.bwt, ax=ax1, c= training.low, cmap = cm.jet)
    # could also do this
    # sns.kdeplot(x_racebwt[['race','bwt']], ax=ax, c= training.low, cmap = cm.jet)
    ax1.set_xlabel("race")
    ax1.set_ylabel("bwt", rotation =0, labelpad=20)
    ax1.set_title("Kernel Density plot of race and birth weight")
    # change tick labels for race
    x_TicksNew = [item for item in ['white','black','other']]
    # change labels
    x_plot_labels = [item.get_text() for item in ax1.get_xticklabels()]
    x_plot_labels[1] = 'White'
    x_plot_labels[2]='Black'
    x_plot_labels[3]='Other'
    ax1.set_xticklabels(x_TicksNew)
    ax1.set_xticks([1,2,3]);
    ax1.hlines(y=2500,xmin=0, xmax=4, color='r', lw=1, linestyle='--');
    
    
    # seaborn kde plot of age and birth weight
    ax2.set_xlabel("Age")
    ax2.set_title("Kernel Density plot of age and birth weight")
    ax2.hlines(y=2500,xmin=0, xmax=55, color='r', lw=1, linestyle='--')
    sns.kdeplot(x_racebwt_2[['age','bwt']], ax=ax2, c= training.low, cmap = cm.cool);

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/kernerl.png)


Also, when looking at the densities of all races, it becomes even more apparent
that white women tend to have averages around 3000g whereas black and other
women have average baby weights below 3000g.


    # plot distribution of each race on top of one another
    fig3, ax = pyplot.subplots(nrows=1, ncols=1, sharey=True, sharex=True, figsize=(6,6))
    whites = x_racebwt.loc[x_racebwt.race==1]
    blacks = x_racebwt.loc[x_racebwt.race==2]
    others = x_racebwt.loc[x_racebwt.race==3]
    # set different colors using seaborn palettes
    c1, c2, c3 = sns.color_palette("Set1", 3)
    
    sns.kdeplot(whites['bwt'], ax = ax, color =c1, label="white");
    sns.kdeplot(blacks['bwt'], ax = ax, color =c2, label="black");
    sns.kdeplot(others['bwt'], ax = ax, color =c3, label="other");
    # add a vertical line for each mean weight by race
    ax.vlines(x=whites.bwt.mean(),ymin=0, ymax=0.0007, color=c1, lw=2, linestyle='--') #add mean for white women
    ax.vlines(x=blacks.bwt.mean(),ymin=0, ymax=0.0007, color=c2, lw=2, linestyle='--') #add mean for black women
    ax.vlines(x=others.bwt.mean(),ymin=0, ymax=0.0007, color=c3, lw=2, linestyle='--') #add mean for other women
    ax.set_title("Density plot of birth weight by race");
    ax.set_xlabel("Birth weight");

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/weightrace_density.png)

#### Distplot
I also briefly explored the distplot function from the seaborn package which
allows you to combine histograms and kernel density plots easily. The below
shows the dist plot (histogram and a kernel density plot on top) of race and
birthweight.


    from scipy import stats
    fig4, (ax1, ax2) = pyplot.subplots(nrows=1, ncols=2, figsize=(12,6))
    # bwt distplot
    sns.distplot(x_racebwt['bwt'], kde=True, hist = True , color ='yellow', 
                 kde_kws={"color": "lightseagreen", "lw": 3, "label": "KDE"}, 
                 ax = ax1);
    ax1.set_title("Birth weight kernel density estimation and histogram");
    
    # Race distplot
    sns.distplot(x_racebwt['race'], kde=True, hist = True , color ='gold', 
                 kde_kws={"color": "green", "lw": 3, "label": "KDE"}, 
                 ax = ax2);
    ax2.set_title("Race kernel density estimation and histogram");

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/distPlot.png)


#### Jointplot
Next, I looked at the jointplot function in the seaborn package to visualize the
joint distribution of lwt and birth weight as well as the marginal distribution
of each variable with a line for the mean of each variable in red.


    x_lwtrace = x.loc[:, ['lwt','race','bwt']]
    print(x_lwtrace.head())
    sns.set_palette("Paired");
    ax = sns.jointplot(x = x_lwtrace.bwt, y = x_lwtrace.lwt, kind="kde", color="dodgerblue", space =0);
    ax.set_axis_labels(ylabel = "lwt", xlabel="bwt");
    ax.ax_marg_x.set_title("Marginal Dist of Birth weight");
    ax.ax_marg_x.axvline(x=x_lwtrace.bwt.mean(), ymin=0, ymax=1, color = c1);
    ax.ax_marg_y.set_title("Marginal Dist of lwt", rotation = 270, fontdict={'horizontalalignment':"right"} );
    ax.ax_marg_y.axhline(y=x_lwtrace.lwt.mean(), xmin=0, xmax=1, color = c1);

       lwt  race   bwt
    0  135     1  3651
    1  110     3  3475
    2  154     3  2442
    3  138     1  2977
    4  170     2  3860


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/joint.png)

###Logistic regression using L1 penalty - yields spare coefficients.

Here I explored the different results and predictions in the training and test
set.
The coefficient plot shows that when the regularization penalty C is set to
1.0 (default), the largest coefficients correspond to smoke (yes/no), race
(black, white or other.) and ptl (history of premature labor).

However, when we decrease C to 0.01, the largest coefficient remaining
corresponds to lwt and the others are nearly 0.


    *L1 model for Logistic Regression*
    l1 = linear_model.LogisticRegression(penalty ='l1', C=1.0, fit_intercept = True) 
    # fit l1 model to data
    l1.fit(x,y)
    #  these are the predictions based on x and L1 model (training set)
    y_pred_train = l1.predict(x)
    # model accuracy 
    model_accuracy = accuracy_score(label_train, y_pred_train)
    # incorrect number of classifications
    incorrect_class = (1-model_accuracy)*train.shape[0]


    print('--------Results on Training set:--------\n')
    print('Coefficients with L1 penalty:\n',l1.coef_)
    print()
    print('Model', l1.penalty, ' score is: ',l1.score(x,y))
    print('Accuracy score is: ', model_accuracy, 'Need to make sure this approach is correct***')
    print('Number of incorrect predictions: ', incorrect_class)

    --------Results on Training set:-----------------
    
    Coefficients with L1 penalty:
     [[-0.00948316  0.01845867  0.5688261   1.00486737  0.53569598  0. 0. 0. -0.00574859]]
    
    Model l1  score is:  0.959677419355
    Accuracy score is:  0.959677419355 Need to make sure this approach is correct***
    Number of incorrect predictions:  5.0


    # get coefficients from L1 model
    coefs = l1.coef_[0]
    # plot coefficients of L1 model and 
    fig = pyplot.figure(facecolor='snow')
    pyplot.plot(coefs, 'ro', markerfacecolor='blue', markersize=14, markeredgecolor = 'r')
    pyplot.xlim(-0.5, 8.5)
    pyplot.xticks(range(len(coefs)), x.columns.values, rotation=45)
    pyplot.axhline(0, color='k', linestyle='--')
    pyplot.title('Coefficient plot - L1 model - C='+ str(l1.C))

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/coef_L1.png)

    # print L1 coefficients
    print('C =',l1.C, ' - L1 coefficients:\n')
    for name, value in zip(x.columns, l1.coef_[0]):
        print('{0}:\t{1:.7f}'.format(name, value))

    C = 1.0  - L1 coefficients:
    
    age:	  -0.0094832
    lwt:	   0.0184587
    race:	   0.5688261
    smoke:	 1.0048674
    ptl:	   0.5356960
    ht:	     0.0000000
    ui:	     0.0000000
    ftv:	   0.0000000
    bwt:	  -0.0057486


    # test set used here
    y_test = np.ravel(label_test)
    # these are the predictions based on x and L1 model (training set)
    y_pred_test = l1.predict(test)
    # model accuracy 
    test_accuracy = accuracy_score(label_test, y_pred_test) # Is this correct???
    # l1 score
    l1_score = l1.score(test,y_test)
    # incorrect number of classifications
    test_incorrect_class = (1-l1_score)*test.shape[0]


    print('-------- L1 Results on Test set:--------\n')
    print('Model', l1.penalty, ' score is: ',l1.score(test,y_test))
    print('Accuracy score is: ', test_accuracy)
    print('Number of incorrect predictions: ', test_incorrect_class)

    -------- L1 Results on Test set:-----------------
    
    Model l1  score is:  0.984615384615
    Accuracy score is:   0.984615384615
    Number of incorrect predictions:  1.0

    result = l1.predict(test)
    print('Predictions on test:')
    print(result)
    predict_prob = l1.predict_proba(test)

    Predictions on test:
    [0 1 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 1 0 0 1 0 1 0 0 1 0 1 0 1 0 0
     1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 1 0]


Changing the regularization term C = 0.01: this yields coefficients very close
to 0.

    #L1: model for Logistic Regression  C = 0.01# 
    l1_v2 = linear_model.LogisticRegression(penalty ='l1', C=.010, fit_intercept = True) 
    # fit l1_v2 model to data
    l1_v2.fit(x,y)
    
    # print L1_v2 coefficients
    print('C =',l1_v2.C, ' - L1 coefficients:')
    for name, value in zip(x.columns, l1_v2.coef_[0]):
        print('{0}:\t{1:.7f}'.format(name, value))
    
    # get coefficients from L1_v2 model
    coefs_v2 = l1_v2.coef_[0]
    
    # plot coefficients of L1 model and 
    fig1 = pyplot.figure(facecolor='cyan')
    pyplot.plot(coefs_v2, 'ro', markerfacecolor='yellow', markersize=14, markeredgecolor = 'r')
    pyplot.xlim(-0.5, 8.5)
    pyplot.xticks(range(len(coefs_v2)), x.columns.values, rotation=45)
    pyplot.axhline(0, color='r', linestyle='--')
    pyplot.grid()
    pyplot.title('Coefficient plot - L1 model - C='+ str(l1_v2.C))

    C = 0.01  - L1 coefficients:
    age:	  0.0000000
    lwt:	  0.0310291
    race:	  0.0000000
    smoke:	0.0000000
    ptl:	  0.0000000
    ht:	    0.0000000
    ui:	    0.0000000
    ftv:	  0.0000000
    bwt:	 -0.0018253


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/coef_L1_2.png)


###Logistic Regression using L2 penalty
When looking at the L2 penalty with C=1.0, the model performs a bit worse
on the test set, and the coefficients are not as close to 0.

From the coefficient plot, smoke appears to be important but so is race. Both
coefficients are penalized the most since L2 penalty uses a square penalty
whereas L1 does not.

When setting C = 1000 the coefficient corresponding to history of premature
labor (ptl) is highest.


    <em>L2 model for Logistic Regression</em>
    l2 = linear_model.LogisticRegression(penalty ='l2', C=1.0, fit_intercept = True) 
    # fit l2 model to data
    l2.fit(x,y)
    # these are the predictions based on x and L1 model (training set)
    y_pred_train_l2 = l2.predict(x)
    # this is L2 model score
    l2_score = l2.score(test, y_test)
    # incorrect number of classifications on test set
    test_incorrect_class_l2 = (1-l2_score)*test.shape[0]


    print('-------- L2 Results on Test set:--------\n')
    print('Model', l2.penalty, ' score is: ',l2.score(test,y_test))
    print('Number of incorrect predictions: ', test_incorrect_class_l2)

    -------- L2 Results on Test set:-----------------
    
    Model l2  score is:  0.907692307692
    Number of incorrect predictions:  6.0



    # print L2 coefficients
    print('C =',l2.C, ' - L2 coefficients:')
    for name, value in zip(x.columns, l2.coef_[0]):
        print('{0}:\t{1:.7f}'.format(name, value))
    
    # get coefficients from L2 model
    coefs_l2 = l2.coef_[0]
    
    # plot coefficients of L2 model and 
    fig2 = pyplot.figure(facecolor='yellow')
    pyplot.plot(coefs_l2, 'ro', markerfacecolor='green', markersize=14, markeredgecolor = 'r')
    pyplot.xlim(-0.5, 8.5)
    pyplot.xticks(range(len(coefs_l2)), x.columns.values, rotation=45)
    pyplot.axhline(0, color='m', linestyle='--')
    pyplot.grid()
    pyplot.title('Coefficient plot - L2 model - C='+ str(l2.C))

    C = 1.0  - L2 coefficients:
    age:	  0.0478285
    lwt:	  0.0289740
    race:	  1.0237721
    smoke:	1.4929413
    ptl:	  0.4912715
    ht:	    0.3326577
    ui:	    0.1681403
    ftv:	 -0.0059294
    bwt:	 -0.0039292

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/coef_L2.png)

Changing C = 1000 for L2 penalty:

    <em>L2: model for Logistic Regression - C = 1000</em>
    l2_v2 = linear_model.LogisticRegression(penalty ='l2', C=1000) 
    # fit l1_v2 model to data
    l2_v2.fit(x,y)
    # print L1_v2 coefficients
    print('C =',l2_v2.C, ' - L2 coefficients:')
    for name, value in zip(x.columns, l2_v2.coef_[0]):
        print('{0}:\t{1:.7f}'.format(name, value))
    
    # get coefficients from L2_v2 model
    coefs_l2_v2 = l2_v2.coef_[0]
    
    # plot coefficients of L2 model and 
    fig3 = pyplot.figure(facecolor='magenta')
    pyplot.plot(coefs_l2_v2, 'ro', markerfacecolor='blue', markersize=14)
    pyplot.xlim(-0.5, 8.5)
    pyplot.ylim(-1.5, 2.2)
    pyplot.xticks(range(len(coefs_l2_v2)+1), x.columns.values, rotation=45)
    pyplot.axhline(0, color='m', linestyle='--')
    pyplot.grid()
    pyplot.title('Coefficient plot - L2 model - C='+ str(l2_v2.C))

    C = 1000  - L2 coefficients:
    age:	 -0.0620169
    lwt:	  0.0294959
    race:	  1.1888958
    smoke:	1.8584039
    ptl:	  2.0503467
    ht:	    1.7983696
    ui:	   -0.9007075
    ftv:	 -0.0505346
    bwt:	 -0.0071715



![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/coef_L2_2.png)

## Predictions
Here I do a simple prediction on a subset of the entire set. I look at the
predictions on the test set based on the features
smoke and race.
Using these 2 features and the L2 penatly, the model predicts at about 70%
accuracy, making 12 mistakes on the test set.

    # create subset with data only for age and race to train
    x_race_data = training.loc[:,['smoke','race','low']]
    x_race_train = x_race_data.loc[:,['smoke','race']]
    x_race_label = x_race_data.loc[:,['low']]
    x_race_train_labels = x_race_label.loc[:,'low'] #make same shape as the predictions
    # make test set for this subset
    x_race_test_data = x_test.loc[:,['smoke','race']]
    x_race_test_label = np.ravel(label_test)


    *L2 model for Logistic Regression - for subset with only 2 features: race and smoke*
    logRegmodel = linear_model.LogisticRegression() 
    # fit l1 model to data
    logRegmodel.fit(x_race_train, x_race_train_labels)
    #  these are the predictions based on x and L2 model (training set)
    x_race_predictions = logRegmodel.predict(x_race_train)
    # this is L2 model score
    logRegmodel_score = logRegmodel.score(x_race_test_data, x_race_test_label)
    # incorrect number of classifications
    test_wrong_class = (1-logRegmodel_score) * x_race_test_data.shape[0]


    print('-------- Results on Test set:--------\n')
    print('Model', logRegmodel.penalty, ' score is: ', logRegmodel_score)
    print('Number of incorrect predictions: ', test_wrong_class)

    -------- Results on Test set:--------
    
    Model l2  score is:  0.707692307692
    Number of incorrect predictions:  19.0


### PCA
Next, I wanted to learn about Principal Component Analysis (PCA) to project the
data into less dimensions. Performing PCA on a dataset returns principal
components of the data (these are eigenvectors) such that the 1st component
has the largest possible variance which accounts for most of the variability in
the dataset. Each principal component is associated with a value (eigen value)
which corresponds to the amount of variance explained by that component.
At first I used the _fit transform_ function to see what the explained variance
ratios would be if I did not reduce the dimensions but kept all 9. Since the
explained variance ratio functions returns the ratios of each explained
variance, the sum should add up to 1. Also, in looking at the _explained
variances_, the highest value is the first one corresponding to the largest
amount of variability in the dataset.


    from sklearn.decomposition import PCA
    from sklearn import decomposition
    pca = decomposition.PCA()
    # use pca.fit_transform(x) on training set (need to use pca.transform(x) on test)
    x_PCA = pca.fit_transform(x)
    # get percentage of variance for each of the components to see which features have highest variance
    print("Variance in data explained by each principal component:\n", pca.explained_variance_)
    
    print("Percentage of variance for each component before chosing k features to reduce to:\n",pca.explained_variance_ratio_)
    
    print("Since k is not set, the sum of variance of all components should be 0:", 
    sum(pca.explained_variance_ratio_))

    Variance in data explained by each principal component:
     [  5.55318219e+05   8.43498408e+02   2.89969495e+01   1.00653828e+00
        7.96284427e-01   2.29567363e-01   1.36490978e-01   9.18962870e-02
        5.03949663e-02]
    
    Percentage of variance for each component before chosing k features to reduce to:
     [  9.98427153e-01   1.51655697e-03   5.21346873e-05   1.80969238e-06
        1.43166921e-06   4.12747647e-07   2.45402175e-07   1.65223731e-07
        9.06069728e-08]
    
    Since k is not set, the sum of variance of all components should be 0: 1.0


## Choosing dimensions
Before chosing how many dimensions to reduce to, I plot the explained variance
of each component to see where the largest variability in the data would be
based on the largest variance. It looks like the most variance could be
explained by just 1 principal component.

When chosing to reduce to 5 dimensions (setting *n_components=5*) and plotting
the explained variance ratios it shows that 99% of the variance can indeed be
explained by just 1 component as the other 3 are close to 0%. I also explored
reducing to 2 dimensions and plotted the explained variance ratios.


    # before selecting k components see where the largest variance is
    pca = PCA()
    pca.fit_transform(x)
    fig_pca = pyplot.figure(num =1, figsize = (4,3), facecolor="snow")
    ax = fig_pca.add_subplot(1,1,1)
    ax.plot(pca.explained_variance_, linewidth = 2, color = "blue")
    ax.axis('tight')
    ax.set_ylabel(ylabel = "Explained\nVariance", rotation = 0, labelpad=30)
    ax.set_xlabel('N components')
    pyplot.title('Explained variance for each component');

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/pca_var.png)


    <em>PCA with 5 components</em>
    N=5
    pca = decomposition.PCA(n_components=N)
    x_PCA = pca.fit_transform(x)
    print(pd.DataFrame(pca.components_.T, columns=['PC-1', 'PC-2', 'PC-3', 'PC-4', 'PC-5'], 
    index=x.columns))
    
    print(pca.explained_variance_ratio_)

               PC-1      PC-2      PC-3      PC-4      PC-5
    age   -0.001058 -0.017813  0.999181 -0.034526 -0.000529
    lwt   -0.008302 -0.999787 -0.017852 -0.001401 -0.004407
    race   0.000253  0.005111 -0.015341 -0.407265 -0.871247
    smoke  0.000139 -0.000054 -0.002066  0.060094  0.269429
    ptl    0.000114  0.001934  0.008569 -0.009781  0.040221
    ht     0.000010 -0.003040 -0.005160  0.004724  0.002950
    ui     0.000184  0.000943  0.001522  0.015106  0.024889
    ftv   -0.000054  0.000098  0.031229  0.910486 -0.407519
    bwt   -0.999965  0.008321 -0.000913 -0.000094 -0.000115
    
    [ 9.98427153e-01  1.51655697e-03 5.21346873e-05 1.80969238e-06  1.43166921e-06]

    # plot the percentage of each variance for each component
    N = 5
    ind = np.arange(N)
    vals = pca.explained_variance_ratio_
    y_breaks = np.arange(0.00,1.25, step=0.25)
    x_plot_labels = ['1','2','3','4','5']
    
    # plot of the 5 PCA component percentages
    fig_pca5 = pyplot.figure(figsize=(6,4))
    ax = fig_pca5.add_subplot(1,1,1)
    ax.bar(ind, pca.explained_variance_ratio_,
           color = ['crimson','DeepPink','Coral','Gold','PeachPuff'])
    ax.annotate(r"%.2f%%" % (vals[0]*100), (ind[0]+0.5, vals[0]), va="bottom", ha="center", fontsize=12)
    ax.annotate(r"%.2f%%" % (vals[1]*100), (ind[1]+ 0.5, vals[1]),va="bottom", ha="center", fontsize=12)
    ax.annotate(r"%.2f%%" % (vals[2]*100), (ind[2]+ 0.5, vals[2]),va="bottom", ha="center", fontsize=12)
    ax.annotate(r"%.2f%%" % (vals[3]*100), (ind[3]+ 0.5, vals[3]),va="bottom", ha="center", fontsize=12)
    ax.annotate(r"%.2f%%" % (vals[4]*100), (ind[4]+ 0.5, vals[4]),va="bottom", ha="center", fontsize=12)
    ax.set_xticklabels(labels = x_plot_labels, fontsize = 12)
    ax.set_ylim(0, 1.0)
    ax.set_xlim(-.5, 5.0)
    ax.set_xticks([0,1,2,3,4,5])
    ax.set_yticks(y_breaks)
    ax.xaxis.set_tick_params(width=0)
    ax.yaxis.set_tick_params(width=1, length=0)
    ax.set_xlabel("Principal Component", fontsize=12)
    ax.set_ylabel("Variance \nExplained (%)", fontsize=12, rotation = 0, labelpad=50);

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/pca_var_2.png)

    <em>PCA based on k = 2</em>
    N=2
    pca = decomposition.PCA(n_components=N)
    x_PCA = pca.fit_transform(x)
    print(pd.DataFrame(pca.components_.T, columns=['PC-1', 'PC-2'], index=x.columns))

               PC-1      PC-2
    age   -0.001058 -0.017813
    lwt   -0.008302 -0.999787
    race   0.000253  0.005111
    smoke  0.000139 -0.000054
    ptl    0.000114  0.001934
    ht     0.000010 -0.003040
    ui     0.000184  0.000943
    ftv   -0.000054  0.000098
    bwt   -0.999965  0.008321


    N = 2
    ind = np.arange(N)
    vals = pca.explained_variance_ratio_
    y_breaks = np.arange(0.00,1.25, step=0.25)
    x_plot_labels = ['1','2',]
    # plot of the two pca component percentages
    fig1 = pyplot.figure(figsize=(6,4))
    ax = fig1.add_subplot(1,1,1)
    ax.bar(ind, pca.explained_variance_ratio_,
           color = ['DeepSkyBlue','DarkBlue'])
    ax.annotate(r"%.2f %%" % (vals[0]*100), (ind[0]+0.5, vals[0]),va="bottom", ha="center", fontsize=12)
    ax.annotate(r"%.2f%%" % (vals[1]*100), (ind[1]+ 0.5, vals[1]),va="bottom", ha="center", fontsize=12)
    ax.set_xticklabels(labels = x_plot_labels, fontsize = 12)
    ax.set_ylim(0, 1.0)
    ax.set_xlim(-.5, 2.0)
    ax.set_xticks([0,1,2])
    ax.set_yticks(y_breaks)
    ax.xaxis.set_tick_params(width=0)
    ax.yaxis.set_tick_params(width=1, length=0)
    ax.set_xlabel("Principal Component", fontsize=12)
    ax.set_ylabel("Variance \nExplained (%)", fontsize=12, rotation = 0, labelpad=40);

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/pca_var_3.png)

    # keep only 2 components with largest variances
    pca.n_components = 2
    x_reduced = pca.fit_transform(x)
    print("x shape before PCA:", np.shape(x), "\nx shape after PCA:", np.shape(x_reduced))
    print("PCA variance ratios:", pca.explained_variance_ratio_)
    print()
    print("Printing components in linear combination format:")
    for component in pca.components_:
        print()
        print(" + ".join("%.5f*%s" % (value, name)
                         for value, name in zip(component, x.columns)))

    x shape before PCA:  (124, 9) 
    x shape after PCA:   (124, 2)
    PCA variance ratios: [ 0.99842715  0.00151656]
    
    Printing components in linear combination format:
    
    -0.00106*age + -0.00830*lwt + 0.00025*race + 0.00014*smoke + 0.00011*ptl + 0.00001*ht 
    + 0.00018*ui + -0.00005*ftv + -0.99996*bwt
    
    -0.01781*age + -0.99979*lwt + 0.00511*race + -0.00005*smoke + 0.00193*ptl + -0.00304*ht 
    + 0.00094*ui + 0.00010*ftv + 0.00832*bwt


    print('explained variance ratio: %s'
          % str(pca.explained_variance_ratio_))
    print('explained variance values: %s'
          % str(pca.explained_variance_))

    explained variance ratio:  [ 0.99842715      0.00151656]
    explained variance values: [ 555318.21922504 843.49840762]

    # 1st scatter = plots datapoints in PCA 1
    # 2nd scatter = plots datapoints in PCA 2
    # x[y==0,0] will return the x's in 0th column where y==0 (pca 1)
    # x[y==0,1] will return the x's in 1th column where y==0 (pca 2)
    fig1 = pyplot.figure(figsize=(6,6))
    ax = fig1.add_subplot(1,1,1)
    ax.scatter(x_reduced[y==0,0], x_reduced[y==0,1], c='red', edgecolor ='b',  s=100)
    ax.scatter(x_reduced[y==1,0], x_reduced[y==1,1], c='green', edgecolor ='b', s=100)
    ax.grid(True)
    ax.set_xlabel('1st Principal Component', color='red')
    ax.set_ylabel('2nd Principal Component', color='green', rotation =0, labelpad=35)
    ax.set_title(label = "Projection by PCA")
    pyplot.show(fig1)

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/pca_proj.png)

    # use whiten this time
    pca_2= PCA(n_components=2, whiten=True)
    pca_2.fit(x)
    x_2 = pca_2.transform(x)
    x_reconstructed = pca_2.inverse_transform(x_2) # x_reconstructed is now reconstructed x with fewer features
    print("Pca explained variance ratio:",pca_2.explained_variance_ratio_)
    print("Data is now centered:", np.round(x_2.mean(axis = 0), decimals=5)) # data is now centered
    print("Data is now standardized:", np.round(x_2.std(axis = 0), decimals=5)) # data now has 1 standard dev
    print("No longer correlated:",np.corrcoef(x_2.T)) # component samples no longer are correlated

    Pca explained variance ratio: [ 0.99842715  0.00151656]
    Data is now centered:         [-0.  0.]
    Data is now standardized:     [ 1.  1.]
    No longer correlated:         [[  1.000 -4.6145] [-4.614 1.000]]

    # Since the first component is so large - keep only one dimension
    pca_1= PCA(n_components=1)
    pca_1.fit(x)
    x_1 = pca_1.transform(x)
    x_1_reconstructed = pca_1.inverse_transform(x_1) 

    # x_reconstructed is now reconstructed x with fewer features
    print("Pca explained variance ratio:",pca_1.explained_variance_ratio_)
    
    pyplot.scatter(x_1_reconstructed[:,0], x_1_reconstructed[:,1],c='b', s=35, alpha=0.9)
    X_n=(x - x.mean(axis=0))/x.std(axis=0) #normalize x

    Pca explained variance ratio: [ 0.99842715]

    # since x_1_reconstructed is reconstructed x with fewer features
    # put into a data frame
    
    x_1_reconstructed_v2 = pd.DataFrame(x_1_reconstructed, 
    columns = ['age','lwt','race','smoke','ptl','ht','ui','ftv','bwt'] )
    
    print(x_1_reconstructed_v2.head())

             age         lwt      race     smoke       ptl        ht        ui  
    0  24.588512  137.069044  1.623209  0.278489  0.086492  0.057356  0.011774   
    1  24.402161  135.606185  1.667792  0.302951  0.106653  0.059098  0.044227   
    2  23.310078  127.033287  1.929063  0.446308  0.224800  0.069307  0.234414   
    3  23.875728  131.473660  1.793737  0.372056  0.163605  0.064019  0.135906   
    4  24.809835  138.806445  1.570260  0.249436  0.062548  0.055287 -0.026769   
    
            ftv          bwt  
    0  0.813197  3650.987707  
    1  0.803707  3474.793007  
    2  0.748095  2442.226486  
    3  0.776900  2977.049252  
    4  0.824467  3860.249767  


    Last but not least, some more pretty graphs!
    from pandas.tools.plotting import andrews_curves
    pyplot.figure()
    andrews_curves(training, 'low')

![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/andrew.png)

    I found this and decided to try it as well, but havent had the time to really look deeply into it: 
    #http://pandas.pydata.org/pandas-docs/version/0.13.1/visualization.html
    
    from pandas.tools.plotting import radviz
    pyplot.figure()
    radviz(training, 'low', colormap='winter')


![](https://github.com/gabya06/datascience/blob/master/LogisticRegression/gaby_assets/radviz.png)
