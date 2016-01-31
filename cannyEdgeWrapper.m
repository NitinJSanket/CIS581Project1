% Wrapper for cannyEdge.m
clc
clear all
close all

I = imread('2.jpg');
E = cannyEdge(I);
figure,
imshow(E);
