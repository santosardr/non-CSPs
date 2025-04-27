#!/usr/bin/python3
import os
import sys
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, roc_curve, auc, f1_score
import matplotlib.pyplot as plt
import numpy as np  # Import numpy

# Modificado para aceitar rótulos
def train_predict(train_file, test_file, class_border, negative_label, positive_label):

    # Read the training ARFF file
    try:
        train_data = pd.read_csv(train_file, comment='@', header=None)
        train_labels_found = train_data.iloc[:, -1].unique()
    except Exception as e:
        print(f"\nError reading or processing training file '{train_file}': {e}")
        sys.exit(1)

    # Verify labels are present ONLY in the training data
    if negative_label not in train_labels_found or positive_label not in train_labels_found:
        print(f"\nError: Expected class labels not found in the training file '{train_file}'.")
        print(f"  Expected Negative Label: '{negative_label}'")
        print(f"  Expected Positive Label: '{positive_label}'")
        print(f"  Labels Found in Training File: {list(train_labels_found)}")
        sys.exit(1)

    # Separate the features (attributes) and the labels from training data
    X_train = train_data.iloc[:, :-1].values  # Convert to numpy array
    y_train_str = train_data.iloc[:, -1].values  # Keep original string labels for conversion

    # Read the testing ARFF file
    try:
        # Ler dados de teste, ignorando a última coluna (que pode ser '?')
        # para X_test, mas precisamos do número de linhas.
        test_data = pd.read_csv(test_file, comment='@', header=None)
        num_test_samples = len(test_data)
        if num_test_samples == 0:
            print(f"\nError: Test file '{test_file}' appears to be empty or invalid.")
            sys.exit(1)
        # Separar features do teste
        X_test = test_data.iloc[:, :-1].values # Convert to numpy array
    except Exception as e:
        print(f"\nError reading or processing test file '{test_file}': {e}")
        sys.exit(1)

    # --- CORREÇÃO PRINCIPAL: Criar y_test baseado no class_border ---
    # Garantir que class_border seja válido
    if not (0 <= class_border < num_test_samples):
         print(f"\nError: class_border ({class_border}) is invalid for the number of test samples ({num_test_samples}).")
         print(f"       It must be >= 0 and < {num_test_samples}.")
         sys.exit(1)

    # Criar y_test: 0 para negativo (primeiras 'class_border' amostras), 1 para positivo (restantes)
    y_test = np.concatenate([np.zeros(class_border, dtype=int),
                             np.ones(num_test_samples - class_border, dtype=int)])
    # --- FIM DA CORREÇÃO PRINCIPAL ---

    # Convert training labels to numerical values (0 and 1)
    # Negative label maps to 0, Positive label maps to 1
    y_train = np.where(y_train_str == negative_label, 0, 1)

    # Create and train the random forest model
    model = RandomForestClassifier()
    model.fit(X_train, y_train)

    # Predict the labels for the testing data
    y_pred = model.predict(X_test) # y_pred terá 0s e 1s

    # Calculate the confusion matrix using sklearn
    try:
        # Ensure a 2x2 matrix by specifying labels
        # Agora y_test e y_pred devem ambos conter 0s e 1s
        confusion = confusion_matrix(y_test, y_pred, labels=[0, 1])
    except ValueError as e:
         print(f"\nError calculating confusion matrix: {e}")
         print(f"Unique y_test values (generated): {np.unique(y_test)}")
         print(f"Unique y_pred values: {np.unique(y_pred)}")
         sys.exit(1)

    # Extract the true positives (TP), false negatives (FN), true negatives (TN), and false positives (FP) from the confusion matrix
    # TN=0,0; FP=0,1; FN=1,0; TP=1,1
    tn = confusion[0][0]
    fp = confusion[0][1]
    fn = confusion[1][0]
    tp = confusion[1][1]

    # Calculate the sensitivity and specificity
    sensitivity = 0
    specificity = 0
    if (tp + fn) > 0:
        sensitivity = tp / (tp + fn) # TPR
    if (tn + fp) > 0:
        specificity = tn / (tn + fp) # TNR

    # Calculate the accuracy
    total_samples = tp + tn + fp + fn # Should equal num_test_samples
    accuracy = 0
    if total_samples > 0:
        accuracy = (tp + tn) / total_samples

    # Print the confusion matrix
    print(f"\n\tConfusion Matrix:")
    print(f"\ta\tb\t<-- classified as")
    print(f"\t{tn}\t{fp}\ta = {negative_label} (True Negative)") # Row 0: Actual Negative
    print(f"\t{fn}\t{tp}\tb = {positive_label} (True Positive)\n") # Row 1: Actual Positive

    # Print the variables involved for debugging
    print(f"True Negatives (TN):\t{tn}")
    print(f"False Positives (FP):\t{fp}")
    print(f"False Negatives (FN):\t{fn}")
    print(f"True Positives (TP):\t{tp}\n")

    # Print the sensitivity, specificity, and accuracy
    print(f"Sensitivity (Recall/TPR): {sensitivity}")
    print(f"Specificity (TNR): {specificity}")
    print(f"Accuracy: {accuracy}\n")

    # Predict the probability of the positive class for the testing data
    y_pred_prob = model.predict_proba(X_test)[:, 1] # Probability of class 1

    # Calculate ROC/AUC/F1 only if both classes are present in y_test
    # Esta verificação agora deve ser baseada se class_border > 0 E class_border < num_test_samples
    roc_auc = float('nan')
    f1 = float('nan')
    unique_y_test = np.unique(y_test) # Deve conter [0, 1] se class_border for válido

    if len(unique_y_test) == 2:
        # Calculate the false positive rate (FPR), true positive rate (TPR), and thresholds for the ROC curve
        fpr, tpr, thresholds = roc_curve(y_test, y_pred_prob)

        # Calculate the area under the ROC curve (AUC)
        roc_auc = auc(fpr, tpr)

        # Calculate F1-score
        f1 = f1_score(y_test, y_pred)

        # Print F1-score and AUC
        print(f"F1-Score: {f1}")
        print(f"AUC: {roc_auc}")

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
    else:
        # This case should ideally not happen if class_border is valid (0 < border < num_samples)
        # but we keep the handling just in case.
        try:
             f1 = f1_score(y_test, y_pred, zero_division=0)
             print(f"F1-Score: {f1}")
        except Exception as e_f1:
             print(f"Could not calculate F1-Score: {e_f1}")

        print(f"AUC: {roc_auc}")
        print("\nWarning: ROC curve and AUC cannot be calculated because only one class is present in the generated true test labels.")
        print(f"Generated unique true test labels: {unique_y_test}")


def main():
    args = sys.argv
    arg_count = len(args)
    test_file = None
    class_border = None
    train_file = None
    negative_label = 'NON-SECRETED' # Default negative label
    positive_label = 'SECRETED'   # Default positive label

    # Updated help message and argument check
    if arg_count < 4 or arg_count == 5: # Need 4 or 6 arguments
        print("Error: Invalid parameters.")
        print("Usage: ./randomforest.py <test_file> <class_border> <train_file> [negative_label positive_label]")
        print("  <test_file>: Path to the testing ARFF file (can have '?' in class column).")
        print("  <class_border>: Integer position threshold separating negatives (first <border> lines)")
        print("                    from positives (remaining lines) in the test file.")
        print("  <train_file>: Path to the training ARFF file (must contain actual class labels).")
        print("  [negative_label positive_label]: Optional. Specify the negative and positive class labels.")
        print("                                     Defaults to 'NON-SECRETED' (negative=0) and 'SECRETED' (positive=1).")
        print("                                     Labels MUST exist in the training file.")
        print("\nExample (default labels): ./randomforest.py ../../validation1.arff 92 ../myids-filter5-89-93-90-a.arff")
        print("Example (custom labels):  ./randomforest.py testes/Corynebacterium/similar.arff 2477 training.tail1.arff NEGATIVE POSITIVE")
        sys.exit(1)

    test_file = args[1]
    try:
        class_border = int(args[2])
    except ValueError:
        print(f"Error: Invalid class_border '{args[2]}'. Must be an integer.")
        sys.exit(1)

    train_file = args[3]

    if arg_count >= 6:
        negative_label = args[4]
        positive_label = args[5]

    print(f"Test file: {test_file}")
    print(f"Test file class border at: {class_border}")
    print(f"Training file: {train_file}")
    print(f"Using Negative Label: '{negative_label}' (will be mapped to 0)")
    print(f"Using Positive Label: '{positive_label}' (will be mapped to 1)")

    # Basic file existence check
    if not os.path.isfile(test_file):
         print(f"Error: Test file not found: {test_file}")
         sys.exit(1)
    if not os.path.isfile(train_file):
         print(f"Error: Training file not found: {train_file}")
         sys.exit(1)

    # Class border basic check (more detailed check inside train_predict)
    if class_border < 0:
         print(f"Error: class_border cannot be negative: {class_border}")
         sys.exit(1)

    train_predict(train_file, test_file, class_border, negative_label, positive_label)


main()
