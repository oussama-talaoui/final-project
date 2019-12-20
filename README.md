# DATA PROCESSES FINAL PROJECT (GROUP 3)

   ## Group Members

| Name                      | Github username           |
|---------------------------|---------------------------|
| ANGULO MONTES LUIS EDUARDO| LuisEduardoAngulo         |
| BORRERO GARCIA FRANCISCO  | Macvayne                  |
| TAHIRI ALAOUI OUSSAMA     | oussama-talaoui           |

In the [report](https://oussama-talaoui.github.io/final-project/) page you can find the answers for the following questions:
### Abstract (**5 points**)

- [ ] A summary of your project and findings.

### Introduction and Related Work (**10 points**)
An explanation of the problem and the motivation for solving it. Make sure to cite at least 5 related works to situate your question within the broader topic area.

- [ ] Provides a clear motivation for answering a _specific_ data driven question of interest (**5 points**)
- [ ] Cites 5 _relevant_ pieces of relevant work (whatever format you choose is fine, including just a hyperlink) (**1 point each**)

### Exploratory Data Analysis (**20 points**)
Your paper should contain at least 5 well designed and formatted graphics that introduce the pertinent features of your dataset. You must also describe the pertinent observations from those graphics.  

- [ ] Introduces the dataset by describing the origin (source) and structure (shape, relevant features) of the data being used (**5 points**)
- [ ] Creates 5 well designed and formatted graphics (**15 points**, 3 each)
  - The visual uses the appropriate visual encodings based on the data type (**1 point**)
  - Written interpretation of graphic is provided (**1 point**)
  - Clear axis labels, titles, and legends are included, where appropriate (**1 point**)

For this work, we used the "Taiwan's credit card default clients" dataset. This one was taken from the UCI Machine Learning Repository and it is composed of 24 features and 30.000 instances. Basically, it contains some demographic and banking information from credit cardholders of a bank in Taiwan for 2005. The features are described as follow:

### Methods (**30 points**)
In this section, you must describe (and perform) the appropriate analysis for answering your question of interest.  Provide a description of both the statistical and machine learning techniques used to answer your question of interest regarding strength of relationships and prediction of your outcome.

The appropriate methods are employed to answer the question of interest, including:

- [ ] **Strength of relationships**: Uses the appropriate technique to assess the strength of relationships amongst your variables of interest. You should include: 
  - A formula describing how you believe your features (independent variables) are related to your outcome of interest (dependent variable) (**5 points**)
  - A defense of the variables included in your formula (**5 points**)
  - Creating the appropriate model based on your dataset (**5 points**)
- [ ] **Prediction**: You must also make predictions for your outcome of interest. In doing so, you must demonstrate a clear use of:
  - Splitting your data into testing/training data (**2 points**)
  - Applying cross validation to your model (**3 points**)
  - Appropriately handling any missing values (**2 points**)
  - Appropriately using categorical variables (**3 points**)
  - Using a grid search to find the best parameters for you model of interest (**2 points**)
  - Employing the algorithm of interest (**3 points**)
  
All the work related to machine learning algorithms and data preparation was done using R software, basically, "mlr" package, and others.

As mentioned before, the dataset did not have any missing values, but the data wrangling and engineering was necessary because of the categorical features, they did not appear as it was stated in the repository. Therefore, the first thing that we did was a dummy encoding for sex, education and marriage features, where the following levels were dropped in each one: men, other education, other marital status.

Furthermore, in the data exploration, we realized that the repayment status was not between the proper range (-1 to 9), it was slid one unit (going for -2 to 8); thus, we added one unit to the scale. Regarding this feature, we chose not to encode as a dummy due to it was ordinal, so it was used like that. 

The proper explanatory data analysis was conducted, checking correlations, skewness, kurtosis, normality distribution and so on; we found issues in the dataset with these measures. For instance, most of the numerical type features presented positive skewness. Moreover, we checked for potential outliers, scaling the features in a range from 0 to a 1, and dropping the ones that showed values higher than 3 (Euclidean distance threshold). The dataset was reduced to 29,265 instances, so we dropped around 735 instances that were potential outliers.

For the proper deployment of the algorithms, the dataset was cut in two parts. The first subset was the training one, correspond to the 80 % of the observations in the original dataset, and it was used to train all the algorithms, also to predict and assess the generalization of the model. On other hand, the test set was only used to evaluate one model (classification tree), to establish how well the model would behave with unseen data.

Once the dataset was split, we proceeded to scale the features because some of them were in different units of measurement. To fulfill this task, we used the min-max scaling function. Afterward, some statistics summery was applied to check the results, we realized that for the machine algorithms deployment we would have some trouble with predictions because the classes of our label feature. To solve this unbalance data issue, we performed a data balance process to avoid that in our prediction the model will be tempted to misclassify the minority class; in general, machine learning algorithms tends to follow the majority, so they will perform well with the most common class and not that good with the uncommon one.

After all the process described before, we applied eight machine learning algorithms on the training set following the "mlr" approach (create a task, create a learner, train, predict, resampling). We implemented the following algorithms: Classification Tree, Logistic Regression, and Neural Network). Basically, we trained each one of them, then obtained a prediction for the training set, observed their performance and finally we evaluated their generalization with a resampling approach.

It is important to remark that for resampling (assessed of the algorithms) it was used repeated cross-validation, setting the parameters in 3 folds and 2 repetitions.

### Results (**20 points**)
Describe the results of your analysis. What did you find? You should include at least 2 visuals that showcase the results (this is distinct from the exploratory analysis above, and should demonstrate the results of the methods you employed). 

You must provide a clear interpretation of your statistical and machine learning results, including at least **one visual or table** for each.

- [ ] **Strengths of relationships**: For the features you included in your model, you must describe the strength (significance) and magnitude of the relationships. This can be presented in a table or chart, and pertinent observations should be described in the text. (**10 points**)
- [ ] **Predictions**: How well were you able to predict values in the dataset? You should both report appropriate metrics based on the type of outcome you're predicting (e.g., root mean squared error v.s. accuracy), as well as a high quality visual showing the strength of your model (**10 points**)

Classification trees: As its name suggests, this algorithm follows a tree structure to predict a class, where each tree has its root node (a relevant feature to predict the class), leaf nodes (following features) and branches (output of the test). Works by partitioning the feature space into a number of smaller scenarios with similar response values using a set of splitting rules. The segmentation process is typically carried out using only one explanatory variable at a time.

### Discussion and Future Work (**10 points**)
What are the real world implications of your results, and what further work should be done in this area based on your insights?

Based on _specific observations_ from the results section, the report clearly provides:

- [ ] An analysis of the real world implications of the results, at least one full paragraph (**5 points**)
- [ ] Clear suggestion for directions of future research, at least one full paragraph (**5 points**)

### Code Quality (**5 points**)

- [ ] Code is well commented and structured (e.g., indented), organized across multiple different files, uses clear variable names, and runs on any computer.

You should submit two URLs for the project: your GitHub repository URL, as well as the URL of the hosted website where your report can be viewed. 