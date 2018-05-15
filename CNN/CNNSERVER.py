from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import numpy as np
import tensorflow as tf
import warnings
import math
import sys
import os
import urllib3
import certifi
import socket
import threading
from bs4 import BeautifulSoup
from tensorflow.python.feature_column.feature_column import input_layer
from cProfile import label
from IPython.core.tests.test_formatters import numpy
from html.parser import HTMLParser
from _ssl import CERT_REQUIRED

warnings.filterwarnings(action='ignore', category=UserWarning, module='gensim')
import gensim as gensim

dir = os.path.dirname(__file__)

tf.logging.set_verbosity(tf.logging.INFO)
print("Loading word2vec model...")
model = gensim.models.KeyedVectors.load_word2vec_format(os.path.join(dir, 'GoogleNews-vectors-negative300.bin'), binary=True)
print("Word2vec loaded")

siteData = []




class threader(threading.Thread):
        def __init__(self,threadID,name,counter):
                threading.Thread.__init__(self)
                self.threadID = threadID
                self.name = name
                self.counter = counter
        def run(self):
                print ("starting " + self.name)
                ServerStart()
                print("Exiting " + self.name)


def ServerStart():
     host = socket.gethostbyname(socket.gethostname())
     port = 5000
     print ("hosting on " + host + ":" + str(port))
     mySocket = socket.socket()
     mySocket.bind((host,port))
     try:
             mySocket.listen(1)
             while True:
                     conn, addr = mySocket.accept()
                     #print ("Connection from: " + str(addr))
                     while True:
                             data = conn.recv(1024).decode()
                             if not data:
                                     break
                             print ("Message Recieved:" + str(data))
                             data = str(data).upper()
                             Scraper(data)
                             print('Data Sent to Scraper')
                             result = predictSite()
                             print(result)
                             print('Sending Result to Web Client')
                             conn.send(str(result).encode())
                             
                             conn.close()
     except:
        conn.close()

class Parser(HTMLParser):
    def handle_data(self, data):
        sentences = data.split('.')
        for sentence in sentences:
            if len(sentence.split()) > 4:
                siteData.append(sentence.strip())
        
def Scraper(URL):
    http = urllib3.PoolManager(cert_reqs = 'CERT_REQUIRED', ca_certs=certifi.where())
    request = http.request('GET', URL)
    soup = BeautifulSoup(request.data.decode(), 'html.parser')
    parser = Parser()
    pTags = soup.find_all('p')
    for p in pTags:
        parser.feed(p.get_text())

def cnn_model_fn(features, labels, mode):
    """Function to model the CNN"""
    
    # Input layer
    print(features["x"])
    input_layer = tf.reshape(features["x"], [-1, 300, 50, 1])
    """ -1 = batch_size (-1 indicates batch size will be set dynamically) """
    """ 300 = word length (word2vec converts words into vectors 300 long) """
    """ 50 = sentence length (sentences less than this will be padded) """
    """ 1 = channels (may use multiple channels for multiple languages etc) """
    
    print(input_layer)
    
    # First convolutional layer
    conv1 = tf.layers.conv2d(
        inputs=input_layer,
        filters=32,
        kernel_size=[300, 3],
        padding="same",
        activation=tf.nn.relu)
    """ inputs = input to conv layer (which is our input_layer) """
    """ filters = no of filters to apply """
    """ kernel_size = size of kernel for convolution (covers 3 words at a time) """
    """ padding = what to do at edges of sentence (same adds zeros) """
    """ activation = activation method (ReLU)"""
    # Output from this is [batch_size, 300, 50, 32]; 32 channels for each filter
    
    print(conv1)
    
    # First pooling layer
    pool1 = tf.layers.max_pooling2d(inputs=conv1, pool_size=[101, 2], strides=2)
    """ inputs = input to pool layer (which is output from conv1) """
    """ pool_size = size of pooling kernel (reduces word size to 10 and halves sentence length) """
    """ strides = how much the kernel moves each time (1 = 1 word at a time) """
    # Output from this is [batch_size, 100, 25, 32]
    
    print(pool1)
    
    # Second convolutional layer
    conv2 = tf.layers.conv2d(
        inputs=pool1,
        filters=64,
        kernel_size=[10, 3],
        padding="same",
        activation=tf.nn.relu)
    #Output from this is [batch_size, 100, 25, 64]
    
    print(conv2)
    
    # Second pooling layer
    pool2 = tf.layers.max_pooling2d(inputs=conv2, pool_size=[100, 1], strides=1)
    # Output from this is [batch_size, 1, 25, 64]; a single value represents each word
    
    print(pool2)
    
    # Flatten output from pool2
    pool2_flat = tf.reshape(pool2, [-1, 25 * 1 * 64])
    """ takes the 64 channels and squashes it down into one """
    """ 10 * 1 * 64 = width * height * channels """
    # Output from this is [batch_size, 640]
    
    print(pool2_flat)
    
    # Dense (fully connected) layer
    dense = tf.layers.dense(inputs=pool2_flat, units=512, activation=tf.nn.relu)
    """ units = no of neurons in the dense layer """
    
    print(dense)
    
    # Add dropout regularisation to dense layer
    dropout = tf.layers.dropout(
        inputs=dense, rate=0.6, training=mode == tf.estimator.ModeKeys.TRAIN)
    """ During training, 40% of the elements will be randomly dropped """
    # Output from this is [batch_size, 512]
    
    print(dropout)
    
    # Logits layer (prediction layer)
    logits = tf.layers.dense(inputs=dropout, units=2)
    """ Gives 2 outputs, one will represent truth, the other fake """
    # Output from this will be [batch_size, 2]
    
    print(logits)
    
    # Create a predictions dictionary
    predictions = {
        # The prediction
        "classes": tf.argmax(input=logits, axis=1),
        # The probabilites of the prediction
        "probabilites": tf.nn.softmax(logits, name="softmax_tensor")
    }
    if mode == tf.estimator.ModeKeys.PREDICT:
        return tf.estimator.EstimatorSpec(mode=mode, predictions=predictions)
    # If we're trying to predict, return the prediction
    
    # Calculate loss when training and evaluating
    onehot_labels = tf.one_hot(indices=tf.cast(labels, tf.int32), depth=2)
    """ This takes the lables (fake or thruth) for the sentence and converts it
        into a tensor. ie [1, 0] represents truth and [0, 1] represents lie.
        The input for lables should be a list of 0's and 1's. 0 representing that
        a statement is true and 1 representing a lie """
        
    print(onehot_labels)
    
    loss = tf.losses.softmax_cross_entropy(
        onehot_labels=onehot_labels, logits=logits)
    # Calculate loss from results compared to actual
    
    # Reduce loss during training using Stochastic gradient descent w/ learning rate of 0.001
    if mode == tf.estimator.ModeKeys.TRAIN:
        optimizer = tf.train.AdamOptimizer(learning_rate=0.0001)
        train_op = optimizer.minimize(
            loss=loss,
            global_step=tf.train.get_global_step())
        return tf.estimator.EstimatorSpec(mode=mode, loss=loss, train_op=train_op)
    
    # Add an accuracy metric for EVAL mode
    eval_metric_ops = {
        "accuracy": tf.metrics.accuracy(
            labels=labels, predictions=predictions["classes"])}
    return tf.estimator.EstimatorSpec(
        mode=mode, loss=loss, eval_metric_ops=eval_metric_ops)

    
""" Reads in data from LIAR dataset given a pathname
    Returns sentences as vectors and corresponding labels """
def read_LIAR_data(pathname):
    sentenceVectors = []
    labels = []
    file = open(pathname, "r", encoding="utf-8")
    lines = file.readlines()
    for line in lines:
        sections = line.split('\t')
        if sections[1] == "pants-fire" or sections[1] == "false" or sections[1] == "barely-true":
            labels.append(1) #One represents a lie
        else:
            labels.append(0) #Zero represents truth
        sentence = sections[2].split()
        vector = GetVectors(sentence)
        sentenceVectors.append(vector)
    return sentenceVectors, labels

""" Converts a given sentence into a vector """
def GetVectors(inputSentence):
    vocab = model.vocab.keys()
    vectors = []
    padding_vector = [0] * 300
    for w in inputSentence:
        if len(vectors) == 50:
            return vectors
        if w in vocab:
            vectors.append(model[w])
        else:
            vectors.append(padding_vector)
    while len(vectors) < 50:
        vectors.append(padding_vector)

    return vectors
            
    
def train():
    # Load in training and evaluation data sets
    print("Reading training set...")
    train_set = read_LIAR_data(os.path.join(dir, "liar_dataset/train.tsv"))
    train_data = np.asarray(train_set[0], dtype=np.float32)
    train_labels = np.asarray(train_set[1], dtype=np.int32)
    print("Training set read. Reading evaluation set...")
    eval_set = read_LIAR_data(os.path.join(dir, "liar_dataset/valid.tsv"))
    eval_data = np.asarray(eval_set[0], dtype=np.float32)
    eval_labels = np.asarray(eval_set[1], dtype=np.int32)
    print("Evaluation set read")
    
    print(len(train_data))
    print(train_labels)
    #return
    
    # Create an estimator
    fake_news_classifier = tf.estimator.Estimator(
        model_fn=cnn_model_fn, model_dir=os.path.join(dir, "CNN Checkpoints"))
    """ Create an estimator, passing the model created above, and a file path to output checkpoints """
    
    # Set up logging for predictions
    tensors_to_log = {"probabilites": "softmax_tensor"}
    logging_hook = tf.train.LoggingTensorHook(
        tensors=tensors_to_log, every_n_iter=50)
    """ Log probabilities every 50 iterations """
    
    # Train the CNN
    train_input_fn = tf.estimator.inputs.numpy_input_fn(
        x={"x": train_data},
        y = train_labels,
        batch_size=100,
        num_epochs=None,
        shuffle=True)
    """ The 'settings' to use for training """
    fake_news_classifier.train(
        input_fn=train_input_fn,
        steps=1000,
        hooks=[logging_hook])
    """ Train the model using the settings and 5000 steps """
    
    # Evaluate the CNN and print the results
    eval_input_fn = tf.estimator.inputs.numpy_input_fn(
        x={"x": eval_data},
        y=eval_labels,
        num_epochs=1,
        shuffle=False)
    """ The 'settings' to use for evaluation """
    eval_results = fake_news_classifier.evaluate(input_fn=eval_input_fn)
    # Evaluate
    print(eval_results)
    # Print results
    
def predict(sentence):
    # Create an estimator
    fake_news_classifier = tf.estimator.Estimator(
        model_fn=cnn_model_fn, model_dir=os.path.join(dir, "CNN Checkpoints"))
    """ Create an estimator, passing the model created above, and a file path to output checkpoints """
    sentence_vec = np.asarray(GetVectors(sentence), dtype=np.float32)
    predict_input_fn = tf.estimator.inputs.numpy_input_fn(
        x={"x": sentence_vec},
        shuffle=False)
    
    predict_results = fake_news_classifier.predict(input_fn=predict_input_fn)
    for pred in predict_results:
        print("Result: {}".format(pred))
        
def predictSite():
    fake_news_classifier = tf.estimator.Estimator(
        model_fn=cnn_model_fn, model_dir=os.path.join(dir, "CNN Checkpoints"))
    """ Create an estimator, passing the model created above, and a file path to output checkpoints """
    site_vecs = []
    for s in siteData:
        site_vecs.append(GetVectors(s))
    input = np.asarray(site_vecs, dtype=np.float32)
    predict_input_fn = tf.estimator.inputs.numpy_input_fn(
        x={"x": input},
        shuffle=False)
    
    predict_results = fake_news_classifier.predict(input_fn=predict_input_fn)
    truthTotal = 0.0
    fakeTotal = 0.0
    count = 0
    for pred in predict_results:
        truthTotal = truthTotal + pred['probabilites'][0]
        fakeTotal = fakeTotal + pred['probabilites'][1]
        count = count + 1
        
    truthAverage = truthTotal / count
    fakeAverage = fakeTotal / count
    print("Result: {} {}".format(truthAverage, fakeAverage))
    return truthAverage


def main(unused_argv):
     while True:
                thread1 = threader(1,"Thread-1",1)
                thread2 = threader(2,"Thread-2",2)
                thread1.start()
                thread1.join()
                thread2.start()
                thread2.join() 
    
    #if len(sys.argv) < 2:
    #    print("No command given")
    #    print("    -t: Train CNN")
    #    print('    -p "Sentence to predict": Predict the given sentence')
    #    return
    #if sys.argv[1] == "-t":
    #    train()
    #elif sys.argv[1] == "-p":
    #    if len(sys.argv) < 3:
    #        print("Enter a sentence in quotes to predict after -p")
    #        return
    #    predict(sys.argv[2])
    #elif sys.argv[1] == "-x":
    #    if len(sys.argv) < 3:
    #        print("Enter a sentence in quotes to predict after -p")
    #        return
    #    Scraper(sys.argv[2])
    #    result = predictSite()
    #else:
    #    print ("Unknown command: {}".format(sys.argv[1]))
        
if __name__ == "__main__":
    tf.app.run()
