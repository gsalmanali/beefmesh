from __future__ import print_function

import keras
import tensorflow as tf
#from keras.datasets import mnist
from keras.models import Sequential, load_model
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import cv2
import time
import os
from IPython.display import clear_output
import matplotlib.pyplot as plt
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.python.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, log_loss, accuracy_score
from sklearn.model_selection import train_test_split
from tensorflow.keras import datasets, layers, models
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
import glob
from os import path
from keras.utils import np_utils


# batch_size = 128
num_classes = 2
epochs = 1
sample_size = 500
width = 100
height = 100
directory = '../'
# epochs = 1

# input image dimensions
img_rows, img_cols = 100, 100
input_shape = (img_rows, img_cols, 1)

def extract_data():
    print("Processing processor data files ...")
    files = ['Fresh', 'Spoiled']
    adress = '/{}'
    data = {}
    p = str(os.getcwd())
    adress = p + adress
    for f in files:
        data[f]=[]
    for col in files:
        os.chdir(adress.format(col))
        for i in os.listdir(os.getcwd()):
            if i.endswith('.jpg'):
                 data[col].append(i)
    image_data = []
    image_target = []

    for title in files:
         os.chdir(adress.format(title))
         counter = 0
         for i in data[title]:
             img = cv2.imread(i)
             img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
             image_data.append(cv2.resize(img,(width, height)))
             image_target.append(title)
             counter += 1
             if counter == sample_size:
                 break
             clear_output(wait=True)
    labels = LabelEncoder()
    labels.fit(image_target)
    image_data = np.array(image_data)
    size = image_data.shape[0]
    X = image_data / 255.0
    y = labels.transform(image_target)
    train_images, test_images, train_labels, test_labels = train_test_split(X,y, test_size=0.3, random_state=123)
    # return x_train, x_test, y_train, y_test
    os.chdir('../')
    print("Done processing image files!")
    return train_images, test_images, train_labels, test_labels


def model_finder():
    p_arr = []
    pmodels = glob.glob("remote_user_models/*.npy")
    print("Processor model files found!:", pmodels)

    for i in pmodels:
        p_arr.append(np.load(i, allow_pickle=True))

    return np.array(p_arr)
    print("Loaded files successfully! ")

def aggregation_FL():
    # Performing federated learning (FL) aggregation! 
    p_arr = model_finder()
    agg_fl = np.average(p_arr, axis=0)
    
    # Check shape of aggregated model! 
    #for i in agg_fl:
        #shp=i
        #print(shp.shape, i)
     

    print("Aggregated Model", agg_fl)

    return agg_fl


def generate_model(weighted_average):
     # 
     pmodel = models.Sequential()
     pmodel.add(layers.Conv2D(35, (3, 3), activation='relu', input_shape=(width,height,3)))
     pmodel.add(layers.MaxPooling2D((2, 2)))
     pmodel.add(layers.Conv2D(64, (3, 3), activation='relu'))
     pmodel.add(layers.MaxPooling2D((2, 2)))
     pmodel.add(layers.Conv2D(64, (3, 3), activation='relu'))
     pmodel.add(layers.Flatten())
     pmodel.add(layers.Dense(64, activation='relu'))
     pmodel.add(layers.Dense(2))
     pmodel.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])



     print("************", weighted_average)

     pmodel.set_weights(weighted_average)

     pmodel.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

     return pmodel

     # pmodel.fit(x_train, y_train,
    #           batch_size=batch_size,
    #           epochs=epochs,
    #           verbose=1,
    #           validation_data=(x_test, y_test))


def model_performance(pmodel, x_test, y_test):
    score_values = pmodel.evaluate(x_test, y_test, verbose=0)

    print("Performance:")
    print('Testing loss scores are:', score_values[0])
    print('Testing accuracy acores are:', score_values[1])
    with open('aggregator_storage/results.txt', 'a') as file_object:
        # Append 'results' at the end of results file
        file_object.write(' Image testing loss is:'+str(score_values[0])+' Image testing accuracy is:'+str(score_values[1])+'\n')
        file_object.close()

def store_model_combined(pmodel):
    # Saving in persistent storage! 

    pmodel.save("aggregator_storage/aggregated_model.h5")
    print("Processor model saved in persistent storage successfully!")

def model_combine():
    # Extract data!
    #_, x_test, _, y_test =  extract_data()
    # Perform averaging! 
    weighted_average = aggregation_FL()
    # Generate model! 
    pmodel = generate_model(weighted_average)
    # Get performance! 
    #model_performance(pmodel, x_test, y_test)
    # Save results! 
    store_model_combined(pmodel)













