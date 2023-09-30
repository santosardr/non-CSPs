#!/usr/bin/python3
import os
import sys
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, roc_curve, auc
import matplotlib.pyplot as plt

def train_predict(train_file, test_file, class_border):

    # Read the training ARFF file
    train_data = pd.read_csv(train_file, comment='@', header=None)

    # Separate the features (attributes) and the labels
    X_train = train_data.iloc[:, :-1]
    y_train = train_data.iloc[:, -1]

    # Read the testing ARFF file
    test_data = pd.read_csv(test_file, comment='@', header=None)

    # Separate the features (attributes) for prediction
    X_test = test_data.iloc[:, :-1]

    # Create and train the random forest model
    model = RandomForestClassifier()
    model.fit(X_train, y_train)

    # Predict the labels for the testing data
    y_pred = model.predict(X_test)

    # Initialize the confusion matrix
    confusion = [[0, 0], [0, 0]]

    # Compare the predicted labels with the actual labels and increment the confusion matrix accordingly
    for i in range(len(y_pred)):
        if i < class_border:
            if y_pred[i] == 'NON-SECRETED':
                confusion[0][0] += 1  # True Negative (NEGATIVE predicted correctly)
            else:
                confusion[0][1] += 1  # False Positive (SECRETED predicted incorrectly)
        else:
            if y_pred[i] == 'SECRETED':
                confusion[1][1] += 1  # True Positive (SECRETED predicted correctly)
            else:
                confusion[1][0] += 1  # False Negative (NEGATIVE predicted incorrectly)

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
    print(f"\n\tConfusion Matrix:")
    print(f"\ta\tb\t<-- classified as")
    print(f"\t{confusion[0][0]}\t{confusion[0][1]}\ta = NEGATIVE")
    print(f"\t{confusion[1][0]}\t{confusion[1][1]}\tb = POSITIVE\n")

    # Print the variables involved for debugging
    print(f"True Negatives:\t{tn}")
    print(f"False Positives:\t{fp}")
    print(f"True Positives:\t{tp}")
    print(f"False Negatives:\t{fn}\n")

    # Print the sensitivity, specificity, and accuracy
    print(f"Sensitivity: {sensitivity}")
    print(f"Specificity: {specificity}")
    print(f"Accuracy: {accuracy}\n")

    # Set the true labels for the testing data based on the limits
    y_test = [0] * class_border + [1] * (len(X_test) - class_border)

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


def main():
    args = sys.argv
    arg_count = len(args)
    test_file = None
    class_border = None
    train_file = None

    if arg_count < 4:
        print("Error: Invalid parameters.")
        print("The first argument must be a test file, the second argument must be an integer, and the third the training file.")
        print("Example: ./randomforest.py validation1.arff 94 src/myids-filter5-89-93-90-a.arff")
        sys.exit()

    test_file = args[1]
    class_border = int(args[2])
    train_file = args[3]
    print(f"Test file: {test_file}")
    print(f"Test file class border at: {class_border}")
    print(f"Training file {train_file}")

    if test_file and train_file:
        if not (os.path.isfile(test_file) and os.path.isfile(train_file)):
            print("Error: Invalid parameters: check if the path is a valid file.")
            sys.exit()
        
        if class_border is None:
            print("Error: Invalid parameters: check class-border parameter.")
            sys.exit()
        
        train_predict(train_file, test_file, class_border)
    else:
        print("Error: Invalid files: check for valid test and training files.")
        sys.exit()
main()
