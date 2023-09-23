import sys
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, roc_curve, auc
import matplotlib.pyplot as plt

# Read the training ARFF file
train_file = sys.argv[1]
train_data = pd.read_csv(train_file, comment='@', header=None)

# Separate the features (attributes) and the labels
X_train = train_data.iloc[:, :-1]
y_train = train_data.iloc[:, -1]

# Read the testing ARFF file
test_file = sys.argv[2]
test_data = pd.read_csv(test_file, comment='@', header=None)

# Separate the features (attributes) for prediction
X_test = test_data.iloc[:, :-1]

# Read the limits for NON-SECRETED and SECRETED
non_secreted_limit = int(sys.argv[3])
secreted_limit = int(sys.argv[4])

# Create and train the random forest model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Predict the labels for the testing data
y_pred = model.predict(X_test)

# Initialize the confusion matrix
confusion = [[0, 0], [0, 0]]

# Compare the predicted labels with the actual labels and increment the confusion matrix accordingly
for i in range(len(y_pred)):
    if i < non_secreted_limit:
        if y_pred[i] == 'NON-SECRETED':
            confusion[0][0] += 1  # True Negative (NON-SECRETED predicted correctly)
        else:
            confusion[0][1] += 1  # False Positive (SECRETED predicted incorrectly)
    else:
        if y_pred[i] == 'SECRETED':
            confusion[1][1] += 1  # True Positive (SECRETED predicted correctly)
        else:
            confusion[1][0] += 1  # False Negative (NON-SECRETED predicted incorrectly)

# Extract the true positives (TP), false negatives (FN), true negatives (TN), and false positives (FP) from the confusion matrix
tp = confusion[1][1]
fn = confusion[1][0]
tn = confusion[0][0]
fp = confusion[0][1]

# Calculate the sensitivity and specificity
if tp + fn == 0:
    sensitivity = 0
else:
    sensitivity = tp / (tp + fn)

specificity = tn / (tn + fp)

# Calculate the accuracy
accuracy = (tp + tn) / (tp + tn + fp + fn)

# Print the confusion matrix
print(f"Confusion Matrix:")
print(f"{confusion[0][0]} {confusion[0][1]}")
print(f"{confusion[1][0]} {confusion[1][1]}")

# Print the variables involved for debugging
print(f"True Positives: {tp}")
print(f"False Negatives: {fn}")
print(f"True Negatives: {tn}")
print(f"False Positives: {fp}")

# Print the sensitivity, specificity, and accuracy
print(f"Sensitivity: {sensitivity}")
print(f"Specificity: {specificity}")
print(f"Accuracy: {accuracy}")

# Rest of the code...

# Set the true labels for the testing data based on the limits
y_test = [0] * non_secreted_limit + [1] * (len(X_test) - non_secreted_limit)

# Predict the probability of the positive class for the testing data
y_pred_prob = model.predict_proba(X_test)[:, 1]

# Calculate the false positive rate (FPR), true positive rate (TPR), and thresholds for the ROC curve
fpr, tpr, thresholds = roc_curve(y_test, y_pred_prob)

# Calculate the area under the ROC curve (AUC)
roc_auc = auc(fpr, tpr)

# Plot the ROC curve
plt.figure()
plt.plot(fpr, tpr, label='ROC curve (AUC = %0.2f)' % roc_auc)
plt.plot([0, 1], [0, 1], 'k--')  # Diagonal line representing random guessing
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver Operating Characteristic')
plt.legend(loc='lower right')
plt.show()
