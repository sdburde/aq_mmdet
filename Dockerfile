# Use PyTorch base image with the specified versions
ARG PYTORCH="1.9.0"
ARG CUDA="11.1"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

# Environment variables
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
    FORCE_CUDA="1"

# Avoid Public GPG key error
RUN rm /etc/apt/sources.list.d/cuda.list \
    && rm /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-key del 7fa2af80 \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub \
    && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# Install required packages
RUN apt-get update \
    && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter Notebook
RUN pip install jupyter notebook

# # Install MMEngine and MMCV
# RUN pip install openmim \
#     && mim install "mmengine>=0.7.1" "mmcv>=2.0.0rc4"
RUN pip install openmim
RUN mim install "mmengine>=0.7.1"
RUN mim install "mmcv==2.1.0"

# Install MMDetection
RUN conda clean --all \
    && git clone https://github.com/open-mmlab/mmdetection.git /mmdetection \
    && cd /mmdetection \
    && pip install --no-cache-dir -e .

# Install a compatible version of setuptools
RUN pip install setuptools==58.0.0

# Install TensorBoard and Future
RUN pip install future tensorboard

RUN apt-get update && apt-get install -y wget tree
 
# Set working directory
WORKDIR /mmdetection

RUN rm -r /mmdetection/configs
RUN rm -r /mmdetection/tools

