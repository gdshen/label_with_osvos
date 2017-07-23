import os
import tensorflow as tf

import osvos
from dataset import Dataset


def run_osvos(imgs_dir, labels_dir, max_training_iters=500):
    # User defined parameters
    gpu_id = 0
    train_model = True
    result_path = os.path.join('data', 'result')

    # Train parameters
    seq_name = 'osvos'
    parent_path = os.path.join('models', 'OSVOS_parent', 'OSVOS_parent.ckpt-50000')
    logs_path = os.path.join('models', 'osvos')

    # Define Dataset
    test_frames = sorted(os.listdir(imgs_dir))
    test_imgs = [os.path.join(imgs_dir, frame) for frame in test_frames]
    label_frames = sorted(os.listdir(labels_dir))
    if train_model:
        train_imgs = [os.path.join(imgs_dir, frame[:-4] + '.jpg') + ' ' + os.path.join(labels_dir, frame) for frame in
                      label_frames]
        dataset = Dataset(train_imgs, test_imgs, './', data_aug=True)
    else:
        dataset = Dataset(None, test_imgs, './')

    # Train the network
    if train_model:
        # More training parameters
        learning_rate = 1e-8
        save_step = max_training_iters
        side_supervision = 3
        display_step = 10
        with tf.Graph().as_default():
            with tf.device('/cpu:' + str(gpu_id)):
                global_step = tf.Variable(0, name='global_step', trainable=False)
                osvos.train_finetune(dataset, parent_path, side_supervision, learning_rate, logs_path,
                                     max_training_iters,
                                     save_step, display_step, global_step, iter_mean_grad=1, ckpt_name=seq_name)

    # Test the network
    with tf.Graph().as_default():
        with tf.device('/cpu:' + str(gpu_id)):
            checkpoint_path = os.path.join('models', seq_name, seq_name + '.ckpt-' + str(max_training_iters))
            osvos.test(dataset, checkpoint_path, result_path)


if __name__ == '__main__':
    run_osvos('data/imgs', 'data/annotations', max_training_iters=10)
