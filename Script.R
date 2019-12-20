library(corrplot)
library(ppcor)
library(dplyr)
library(GGally)
library(tseries)
library(purrr)
library(tidyr)
library(readxl)
library(recipes)
library(mlr)
library(mlbench)
library(e1071)
library(rpart)
library(kernlab)
library(nnet)
library(unbalanced)
library(DiscriMiner)
library(praznik)
library(RWeka)
library(gridExtra)
library (rpart.plot)
library(rstudioapi)

current_path <- getActiveDocumentContext()$path 
# The next line set the working directory to the relevant one:
setwd(dirname(current_path ))
# you can make sure you are in the right directory
print( getwd() )

bd <- read_excel("data/default-of-credit-card-clients.xls")

bd <- bd[,-1] #droping the ID features
View(bd)

#data wrangling

dim(bd) 
str(bd) 

#assess if we have missing values
sum(is.na(bd))

#rename features, to work better with them
bd <- bd %>%
rename (BAL = LIMIT_BAL, RPSEP = PAY_0, RPAGO = PAY_2, 
        RPJUL = PAY_3, RPJUN = PAY_4, RPMAY = PAY_5, 
        RPABR = PAY_6, BILLSEP = BILL_AMT1, BILLAGO = BILL_AMT2,
        BILLJUL = BILL_AMT3, BILLJUN = BILL_AMT4, BILLMAY = BILL_AMT5,
        BILLABR = BILL_AMT6, PREPAYSEP = PAY_AMT1, PREPAYAGO = PAY_AMT2,
        PREPAYJUL = PAY_AMT3, PREPAYJUN = PAY_AMT4, PREPAYMAY = PAY_AMT5,
        PREPAYABR = PAY_AMT6, DEFAULT = `default payment next month`)

#we realize that the values of some features where different to the stated in the repository so we must change that
#changing the values
bd <- bd%>%
  mutate(RPSEP = RPSEP + 1,
         RPAGO = RPAGO + 1,
         RPJUL = RPJUL + 1,
         RPJUN = RPJUN + 1,
         RPMAY = RPMAY + 1,
         RPABR = RPABR + 1)

#Dummy encoding
bd <- bd %>%
  mutate(EDUCATION = ifelse(EDUCATION >= 4 | EDUCATION == 0, 4, EDUCATION),
         MARRIAGE = ifelse(MARRIAGE == 0, 3, MARRIAGE))

bd <- bd %>%
  mutate(MUJER = ifelse (SEX == 2, 1, 0), #0 hombre & 1 mujer,
         PREGRADO = ifelse (EDUCATION == 2, 1, 0), 
         HSCHOOL = ifelse (EDUCATION == 3, 1, 0),
         POSGRADO = ifelse (EDUCATION == 1, 1, 0),
         SINGLE = ifelse (MARRIAGE == 2, 1, 0),
         MARRIED = ifelse (MARRIAGE == 1, 1, 0))
         
#recategorize RP feature
bd <- bd %>%
  mutate(RPSEP = ifelse(RPSEP == 0, -1, RPSEP),
         RPAGO = ifelse(RPAGO == 0, -1, RPAGO),
         RPJUL = ifelse(RPJUL == 0, -1, RPJUL),
         RPJUN = ifelse(RPJUN == 0, -1, RPJUN),
         RPMAY = ifelse(RPMAY == 0, -1, RPMAY),
         RPABR = ifelse(RPABR == 0, -1, RPABR))

#Turning into a categorical feature (factor)
bd$DEFAULT <- factor(bd$DEFAULT, levels = c(0,1))
bd$EDUCATION <- factor(bd$EDUCATION, levels = c(1:4))

#Graphics

#1.Basic graph to check the distribution 3 features
#Histograms

ggplot(data = bd) +
  aes(x = BAL)+
  geom_histogram(bins = 30, color="cornsilk4", fill="darkblue") +
  labs(title = "Credit Balance - Histogram", x = "Amount of the given credit (NT$)", y = "Frequency") 

ggplot(data = bd) +
  aes(x = BILLSEP)+
  geom_histogram(bins = 30, color="cornsilk4", fill="darkblue") +
  labs(title = "Amount of bill in September - Histogram", x = "Amount of bill statement in September (NT$)", y = "Frequency") 

ggplot(data = bd) +
  aes(x = PREPAYSEP)+
  geom_histogram(bins = 30, color="cornsilk4", fill="darkblue") +
  labs(title = "Amount of previous payment in September - Histogram", x = "Amount of previous payment in September (NT$)", y = "Frequency") 

#2.Lets go deeper to understand the behavior of the default payment regarding the balance in the account

ggplot(data = bd) +
  aes(x = DEFAULT, y = BAL)+
  geom_boxplot(color="cornsilk4", fill="darkblue",
               notch = TRUE,
               notchwidth = 0.8,
               outlier.colour="red",
               outlier.fill="red",
               outlier.size=3) +
  labs(title = "Credit Balance and Default payment - Boxplot", subtitle="Defaulter Info based on Credit Given", x = "Default payment", y = "Amount of the given credit (NT$)") +  
  theme(panel.background = element_rect(fill = "gray97"))

#3.Graph 3

ggplot(data = bd) +
  aes(x = EDUCATION, fill = DEFAULT)+
  geom_bar() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Default payment and level of education", x = "Education level", y = "Observation count") +
  scale_x_discrete(labels = c('Graduate School','University','High School', 'Others'))

#4.Graph 4

g1 <- ggplot(data = bd) +
  aes(x = factor(RPSEP), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in September and default payment", y = "Observation count", x = "Repayment status in September") 
  
g2 <- ggplot(data = bd) +
  aes(x = factor(RPAGO), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in August and default payment", y = "Observation count", x = "Repayment status in August") 

g3 <- ggplot(data = bd) +
  aes(x = factor(RPJUL), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in July and default payment", y = "Observation count", x = "Repayment status in July") 

g4 <- ggplot(data = bd) +
  aes(x = factor(RPJUN), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in June and default payment", y = "Observation count", x = "Repayment status in June") 

g5 <- ggplot(data = bd) +
  aes(x = factor(RPMAY), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in May and default payment", y = "Observation count", x = "Repayment status in May") 

g6 <- ggplot(data = bd) +
  aes(x = factor(RPABR), fill = DEFAULT)+
  geom_bar() +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Repayment status in April and default payment", y = "Observation count", x = "Repayment status in April") 

#Aggregate graph
grid.arrange(g1,g2,g3,g4,g5,g6)

#5.Graph

ggplot(bd) +
  aes(x=BAL, y=AGE, color=DEFAULT) + 
  geom_point(size=3) +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Credit Balance, age of the credit holder and default payment", y = "Age", x = "Amount of the given credit (NT$)") 

bd <- bd[,-2:-4] #removing sex, education $ marital status features, these ones were the original, we are dropping these because we have a dummy features for each one

### Methods

#correlation
bd$DEFAULT <- as.numeric(bd$DEFAULT)
cor(bd)
corrplot(cor(bd))
corrplot.mixed(cor(bd))

#Skewness and Curtosis
apply(bd[,c(1,9:20)],2,kurtosis)
apply(bd[,c(1,9:20)],2,skewness)

#Normality
apply(bd[,1:20],2,jarque.bera.test)

#Outliers
#Using the euclidean distances (if its higher than 3 is a unsual case)
bd <- bd%>%
  mutate(out_BAL = abs(scale(bd$BAL)),
        out_SEP = abs(scale(bd$BILLSEP)),
        out_AGO = abs(scale(bd$BILLAGO)),
        out_JUL = abs(scale(bd$BILLJUL)),
        out_JUN = abs(scale(bd$BILLJUN)),
        out_MAY = abs(scale(bd$BILLMAY)),
        out_ABR = abs(scale(bd$BILLABR)))

#removing the potencial outlier
bd <- bd%>%
  filter(out_BAL < 3 | out_SEP < 3 | out_AGO < 3 | out_JUL < 3 |
           out_JUN < 3, out_MAY < 3, out_ABR <3)

#removing the variables created for check the outlier
table(bd$DEFAULT)
bd <- bd[,-28:-34]

#Split the dataset

bd$DEFAULT <- factor(bd$DEFAULT, levels = c(0,1))
set.seed(100)
index_1 <- sample(1:nrow(bd), round(nrow(bd) * 0.8))
train <- bd[index_1, ]
test  <- bd[-index_1, ]
summary(train)

#Normalize
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

train <- replace(train, 1:20,(apply(train[,1:20],2,normalize)))
test <- replace(test, 1:20,(apply(test[,1:20],2,normalize)))

#Balance the dataset
Y <- train[,21]
X <- train[,-21]
balance_train <- ubSMOTE(X = X, Y = Y$DEFAULT, perc.over = 100, perc.under = 300, k=3)
btrain <- as.data.frame(cbind(X = balance_train$X, DEFAULT = balance_train$Y))
table(btrain$DEFAULT)/nrow(btrain)

YT <- test[,21]
XT <- test[,-21]
balance_test <- ubSMOTE(X = XT, Y = as.factor(YT$DEFAULT), perc.over = 100, perc.under = 300, k=3)
btest <- as.data.frame(cbind(X = balance_test$X, DEFAULT = balance_test$Y))
table(btest$DEFAULT)/nrow(btest)

##ML WITH MLR PACKAGE------------------------------------
bd <- read_excel("data/default-of-credit-card-clients.xls")

bd <- bd[,-1] #droping the ID features

#data wrangling

#rename features, to work better with them
bd <- bd %>%
  rename (BAL = LIMIT_BAL, RPSEP = PAY_0, RPAGO = PAY_2, 
          RPJUL = PAY_3, RPJUN = PAY_4, RPMAY = PAY_5, 
          RPABR = PAY_6, BILLSEP = BILL_AMT1, BILLAGO = BILL_AMT2,
          BILLJUL = BILL_AMT3, BILLJUN = BILL_AMT4, BILLMAY = BILL_AMT5,
          BILLABR = BILL_AMT6, PREPAYSEP = PAY_AMT1, PREPAYAGO = PAY_AMT2,
          PREPAYJUL = PAY_AMT3, PREPAYJUN = PAY_AMT4, PREPAYMAY = PAY_AMT5,
          PREPAYABR = PAY_AMT6, DEFAULT = `default payment next month`)

#we realize that the values of some features where different to the stated in the repository so we must change that
#changing the values
bd <- bd%>%
  mutate(RPSEP = RPSEP + 1,
         RPAGO = RPAGO + 1,
         RPJUL = RPJUL + 1,
         RPJUN = RPJUN + 1,
         RPMAY = RPMAY + 1,
         RPABR = RPABR + 1)

#Dummy encoding
bd <- bd %>%
  mutate(EDUCATION = ifelse(EDUCATION >= 4 | EDUCATION == 0, 4, EDUCATION),
         MARRIAGE = ifelse(MARRIAGE == 0, 3, MARRIAGE))

bd <- bd %>%
  mutate(MUJER = ifelse (SEX == 2, 1, 0), #0 hombre & 1 mujer,
         PREGRADO = ifelse (EDUCATION == 2, 1, 0), 
         HSCHOOL = ifelse (EDUCATION == 3, 1, 0),
         POSGRADO = ifelse (EDUCATION == 1, 1, 0),
         SINGLE = ifelse (MARRIAGE == 2, 1, 0),
         MARRIED = ifelse (MARRIAGE == 1, 1, 0))

#recategorize RP feature
bd <- bd %>%
  mutate(RPSEP = ifelse(RPSEP == 0, -1, RPSEP),
         RPAGO = ifelse(RPAGO == 0, -1, RPAGO),
         RPJUL = ifelse(RPJUL == 0, -1, RPJUL),
         RPJUN = ifelse(RPJUN == 0, -1, RPJUN),
         RPMAY = ifelse(RPMAY == 0, -1, RPMAY),
         RPABR = ifelse(RPABR == 0, -1, RPABR))

bd <- bd[,-2:-4] #removing sex, education $ marital status features, these ones were the original, we are dropping these because we have a dummy features for each one

#Outliers
#Using the euclidean distances (if its higher than 3 is a unsual case)
bd <- bd%>%
  mutate(out_BAL = abs(scale(bd$BAL)),
         out_SEP = abs(scale(bd$BILLSEP)),
         out_AGO = abs(scale(bd$BILLAGO)),
         out_JUL = abs(scale(bd$BILLJUL)),
         out_JUN = abs(scale(bd$BILLJUN)),
         out_MAY = abs(scale(bd$BILLMAY)),
         out_ABR = abs(scale(bd$BILLABR)))

#removing the potencial outlier
bd <- bd%>%
  filter(out_BAL < 3 | out_SEP < 3 | out_AGO < 3 | out_JUL < 3 |
           out_JUN < 3, out_MAY < 3, out_ABR <3)

#removing the variables created for check the outlier
table(bd$DEFAULT)
bd <- bd[,-28:-34]

#Split the dataset

bd$DEFAULT <- factor(bd$DEFAULT, levels = c(0,1))
set.seed(100)
index_1 <- sample(1:nrow(bd), round(nrow(bd) * 0.8))
train <- bd[index_1, ]
test  <- bd[-index_1, ]
summary(train)

#Normalize
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

train <- replace(train, 1:20,(apply(train[,1:20],2,normalize)))
test <- replace(test, 1:20,(apply(test[,1:20],2,normalize)))

#Balance the dataset
Y <- train[,21]
X <- train[,-21]
balance_train <- ubSMOTE(X = X, Y = Y$DEFAULT, perc.over = 100, perc.under = 300, k=3)
btrain <- as.data.frame(cbind(X = balance_train$X, DEFAULT = balance_train$Y))
table(btrain$DEFAULT)/nrow(btrain)

YT <- test[,21]
XT <- test[,-21]
balance_test <- ubSMOTE(X = XT, Y = as.factor(YT$DEFAULT), perc.over = 100, perc.under = 300, k=3)
btest <- as.data.frame(cbind(X = balance_test$X, DEFAULT = balance_test$Y))
table(btest$DEFAULT)/nrow(btest)


#task
btrain$DEFAULT <- factor(btrain$DEFAULT, levels = c(0,1))
clasificacion.task <- makeClassifTask(id = "task", data = btrain, target = "DEFAULT", positive = "1")
clasificacion.task
getTaskFeatureNames(clasificacion.task)

##DECISION TREE----

#Learner
getParamSet("classif.rpart")
learner.dt <- makeLearner("classif.rpart", 
                         predict.type = "response")

#Train
mod.dt <- mlr::train(learner.dt, clasificacion.task)
getLearnerModel(mod.dt)

#Predict
predict.dt <- predict(mod.dt, task = clasificacion.task)
head(as.data.frame(predict.dt))
calculateConfusionMatrix(predict.dt)

predict.test.dt <- predict(mod.dt, newdata = btest)#TEST PREDICTION

#Performance
listMeasures(clasificacion.task)
performance(predict.dt, measures = list(acc, mmce, kappa))
performance(predict.test.dt, measures = list(acc, mmce, kappa))#PERFORMANCE TEST

#Resampling
RCV.dt <- repcv(learner.dt, clasificacion.task, folds = 3, reps = 2, 
             measures = list(acc, mmce, kappa), stratify = TRUE)
RCV.dt$aggr

#GRAPH OF THE TREE
rpart.plot(mod.dt$learner.model,  box.palette="RdBu", shadow.col="gray", nn=TRUE)

##LOGISTIC----

#learner
getParamSet("classif.logreg")
learner.lr <- makeLearner("classif.logreg",
                         predict.type = "response")

#Train
mod.lr <- mlr::train (learner.lr, clasificacion.task)
getLearnerModel(mod.lr)
summary(mod.lr$learner.model)#OUTPUT

#Prediction
predict.lr <- predict(mod.lr, clasificacion.task)
calculateConfusionMatrix(predict.lr)

#Performance
performance(predict.lr, measures = list(acc, mmce, kappa))

#Resampling
RCV.lr <- repcv(learner.lr, clasificacion.task, folds = 3, reps = 2, 
                measures = list(acc, mmce, kappa), stratify = TRUE)
RCV.lr$aggr

##Neural Network----

#learner
getParamSet("classif.nnet")
learner.nn <- makeLearner("classif.nnet", 
                          predict.type = "response")
learner.nn$par.set

#Train
mod.nn <- mlr::train(learner.nn, clasificacion.task)
getLearnerModel(mod.nn)

#Predict
predict.nn <- predict(mod.nn, task = clasificacion.task)
head(as.data.frame(predict.nn))
calculateConfusionMatrix(predict.nn)

predict.test.nn <- predict(mod.nn, newdata = btest)

#Performance
performance(predict.nn, measures = list(acc, mmce, kappa))
performance(predict.test.nn, measures = list(acc, mmce, kappa))

#Resampling
RCV.nn <- repcv(learner.nn, clasificacion.task, folds = 3, reps = 2, 
             measures = list(acc, mmce, kappa), stratify = TRUE)

RCV.nn$aggr

##Benchmark----

#to compare between models
lrns <- list(learner.dt, learner.lr, learner.nn)
rdesc <- makeResampleDesc("RepCV", folds = 3, reps = 2) #Choose the resampling strategy
bmr <- benchmark(lrns, clasificacion.task, rdesc, measures = list(acc, mmce, kappa))
getBMRPerformances(bmr, as.df = TRUE)
getBMRAggrPerformances(bmr, as.df = TRUE)

