# About Pull Request

This repository is read-only, so Pull Request is not accepted. Thank you for your understanding.

# Caution

If you use this software for commercial, you must pay fees to NVIDIA.

# Julius

Julius is a go engine, written by Julia.

This software uses Convolutional Policy Network.

## Convolutional Policy Network

Policy Network predicts best move of current position.

### Input Features of Neural Network

(1) position of stones

(2) empty square

(3) previous n moves

(4) turn

### Output Labels of Policy Neural Network

square of move to

## Learning functions

Learning functions are written by Julia. Policy Neural Network learns multi task classification. This functions use Flux, which is a machine learning framework.

### Record format for learning

Record format for learning is as below.

black_player,white_player,W+Resign,qd,dc,dq,pq,ce,fd,qo,oc,op, ...

First and second columns are players. Third column is game result. The following columns are moves. When learning Value Neural Network, you use third column. And learning Policy Neural Network, you use columns from third column to last column.

This software use the records on the internet download by myself.

##Source Code Explanation

(1) analyze.jl : functions to analyze a record.

(2) board.jl : functions about go board.

(3) color.jl : variables about color.

(4) common.jl : common variables and structs.

(5) debug.jl : functions to debug.

(6) feature1.jl : functions to generate input features for Policy Network.

(7) hash.jl : functions about hash.

(8) io.jl : functions about input files.

(9) learn1.jl : functions to learn parameters of Policy Network.

(10) main.jl : entry point.

(11) makemove.jl : functions to do move.

(12) position.jl : functions to positions used in learn1.jl.

(13) record.jl : struct about a record.

(14) table.jl : functions about the table to get neighbour squares.

(15) test.jl : test module.

## Operating environment

(1) OS: Windows 11 Pro

(2) Memory: 16GB or more.

(3) Julia Version: 1.12.2

(4) Julia Packages: CUDA v5.8.5, Flux v0.16.5, JLD2 v0.6.3, MLJ v0.22.0, cuDNN v1.4.5

(5) CUDA Version: 13.0

(6) cuDNN Version: 9.14

## References

I developed this software referring to the softwares as below.

dlshogi

As far as I know, the source code for dlshogi is currently not publicly available.

I developed this software referring to the books as below. All books are written in Japanese, so I write the name of the books in Japanese.

(1) 山岡忠夫(2018),『将棋AIで学ぶディープラーニング』マイナビ出版 

(2) 山岡忠夫、加納邦彦(2021), 『強い将棋ソフトの創りかた　Pythonで実装するディープラーニング将棋AI』マイナビ出版

(3) 大槻知史(著)、三宅陽一郎(監修)(2018), 『最強囲碁AI アルファ碁解体新書　増補改訂版』翔泳社

(4) 原田達也(2017), 機械学習プロフェッショナルシリーズ『画像認識』講談社
