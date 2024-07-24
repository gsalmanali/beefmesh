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



#batch_size = 128
#num_classes = 2
epochs = 1
sample_size = 500
width = 100
height = 100
directory = '../'

# input image dimensions
#img_rows, img_cols = 100, 100
#input_shape = (img_rows, img_cols, 3)
def extract_data():
    print("Extracting data for testing and training...")
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
    print("Done Processing!")
    return train_images, test_images, train_labels, test_labels

    """
    (x_train, y_train), (x_test, y_test) = mnist.load_data()
    x_train = x_train.reshape(x_train.shape[0], img_rows, img_cols, 1)
    x_test = x_test.reshape(x_test.shape[0], img_rows, img_cols, 1)
    x_train = x_train.astype('float32')
    x_test = x_test.astype('float32')
    x_train /= 255
    x_test /= 255

    print(x_test.shape[0], 'test samples')

    y_train = keras.utils.np_utils.to_categorical(y_train, num_classes)
    y_test = keras.utils.np_utils.to_categorical(y_test, num_classes)
    """



#def model_generate(x_train, y_train, x_test, y_test):

def model_generate(train_images, test_images,train_labels,test_labels):
    # for every new update in model, the new weights are set to the model weight
    if path.exists("new_model/aggregated_model.h5"):
        print("Found aggregated model in storage")
        print("Starting to read model details! ... ")

        pmodel = load_model("new_model/aggregated_model.h5")

    else:
        print("Did not find aggregated model in storage")
        print("Building new model instead of aggregating! ... ")
        # Model Parameters! 
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

    pmodel.fit(train_images, train_labels, epochs=epochs,
                    validation_data=(test_images, test_labels))


    return pmodel

    """
        pmodel = Sequential()
        pmodel.add(Conv2D(32, kernel_size=(3, 3),
                         activation='relu',
                         input_shape=input_shape))

        pmodel.add(Conv2D(64, (3, 3), activation='relu'))
        pmodel.add(MaxPooling2D(pool_size=(2, 2)))
        pmodel.add(Dropout(0.25))
        pmodel.add(Flatten())
        pmodel.add(Dense(128, activation='relu'))
        pmodel.add(Dropout(0.5))
        pmodel.add(Dense(num_classes, activation='softmax'))

        pmodel.compile(loss=keras.losses.categorical_crossentropy,
                      optimizer=tf.keras.optimizers.Adadelta(),
                      metrics=['accuracy'])

        pmodel.compile(loss=keras.losses.categorical_crossentropy,
                      optimizer=tf.keras.optimizers.Adadelta(),
                      metrics=['accuracy'])

    pmodel.fit(x_train, y_train,
              batch_size=batch_size,
              epochs=epochs,
              verbose=1,
              validation_data=(x_test, y_test))
    """
    

#def model_performance(model, x_test, y_test):
def model_performance(pmodel, test_images, test_labels):    


   # scores = pmodel.evaluate(x_test, y_test, verbose=0)

    result=pmodel.evaluate(test_images, test_labels, verbose=0)

    print('Image testing loss is:', result[0])
    print('Image testing accuracy is:', result[1])
    with open('local_storage/results.txt', 'a') as file_object:
        # Append 'results' at the end of results file
        file_object.write(' Image testing loss is:'+str(result[0])+' Image testing accuracy is:'+str(result[1])+'\n')
        file_object.close()

def update_local_model(pmodel):
    model1 = pmodel.get_weights()
    np.save('local_storage/processor_model1', model1)

    print("Model updated locally!")

def learnmodel():
    train_images, test_images, train_labels, test_labels = extract_data()
   # x_train, x_test, y_train, y_test =  extract_data()
    pmodel = model_generate(train_images, test_images, train_labels, test_labels)
    # pmodel = extract_model(x_train, y_train, x_test, y_test)
   # model_performance(model, x_test, y_test)
    model_performance(pmodel, test_images, test_labels)
    update_local_model(pmodel)













