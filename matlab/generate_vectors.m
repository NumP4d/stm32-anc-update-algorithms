clear;
close all;
clc;

load('B_iir_q15.mat');
load('A_iir_q15.mat');
load('scale_iir_q15.mat');
load('B_decim_q15.mat');
load('B_interp_q15.mat');

%% IIR filter test vector
Fs   = 2000;
T    = 20;
time = 0:1/Fs:T;

f1 = 50;
f2 = 5;
f3 = 40;
f4 = 100;
f5 = 900;

sine_wave = @(f) sin(2*pi*f*time);
input = 0.3 + 0.2 * sine_wave(f1) + 0.1 * sine_wave(f2) + ...
        0.4 * sine_wave(f3) + 0.3 * sine_wave(f4) + 0.4 * sine_wave(f5);
% Normalization
input = input ./ max(abs(input * 32768 / 32767));

B = B_iir_q15;
A = [32768^2/scale_iir_q15, A_iir_q15];
expect = filter(B, A, input);

mkdir iir3;
fid_in = fopen('iir3/input_vector.csv', 'w');
fid_expect = fopen('iir3/expect_vector.csv', 'w');

fprintf(fid_in, "%f\n", input);
fprintf(fid_expect, "%f\n", expect);


%% FIR decim filter test vector and also for non-decimated FIR circular testing
Fs   = 8000;
T    = 20;
time = 0:1/Fs:T;

% Decimation ratio
n = 4;

f1 = 5;
f2 = 50;
f3 = 100;
f4 = 500;
f5 = 800;
f6 = 1000;
f7 = 1500;
f8 = 3999;

sine_wave = @(f) sin(2*pi*f*time);
input = 0.3 + 0.2 * sine_wave(f1) + 0.1 * sine_wave(f2) + ...
        0.4 * sine_wave(f3) + 0.3 * sine_wave(f4) + 0.4 * sine_wave(f5) + ...
        0.2 * sine_wave(f6) + 0.3 * sine_wave(f7) + 0.4 * sine_wave(f8);
% Normalization
input = input ./ max(abs(input * 32768 / 32767));

B = B_decim_q15 / 32768;
expect0 = filter(B, 1, input);
expect = expect0(n:n:end);

mkdir fir_decim;
fid_in = fopen('fir_decim/input_vector.csv', 'w');
fid_expect = fopen('fir_decim/expect_vector.csv', 'w');

fprintf(fid_in, "%f\n", input);
fprintf(fid_expect, "%f\n", expect);

mkdir fir_circular;
fid_in = fopen('fir_circular/input_vector.csv', 'w');
fid_expect = fopen('fir_circular/expect_vector.csv', 'w');

fprintf(fid_in, "%f\n", input);
fprintf(fid_expect, "%f\n", expect0);

%% FIR interp filter test vector
Fs   = 2000;
T    = 20;
time = 0:1/Fs:T;

% Interpolation ratio
n = 4;

f1 = 5;
f2 = 50;
f3 = 100;
f4 = 500;
f5 = 800;
f6 = 999;

sine_wave = @(f) sin(2*pi*f*time);
input = 0.3 + 0.2 * sine_wave(f1) + 0.1 * sine_wave(f2) + ...
        0.4 * sine_wave(f3) + 0.3 * sine_wave(f4) + 0.4 * sine_wave(f5) + ...
        0.2 * sine_wave(f6);
    
% Normalization
input = input ./ max(abs(input * 32768 / 32767));

B = B_interp_q15 / 32768;

% Put zeros to input vector as feed for interpolation filter
feed = zeros(1, length(input) * n);
feed(n:n:end) = input;

expect = filter(B, 1, feed);

mkdir fir_interp;
fid_in = fopen('fir_interp/input_vector.csv', 'w');
fid_expect = fopen('fir_interp/expect_vector.csv', 'w');

fprintf(fid_in, "%f\n", input);
fprintf(fid_expect, "%f\n", expect);

%% LNLMS test vector
Fs   = 2000;
T    = 20;
time = 0:1/Fs:T;

alpha = 32767/32768;
mu    = 0.01;

% Interpolation ratio
f1 = 5;
f2 = 50;
f3 = 100;
f4 = 500;
f5 = 800;
f6 = 999;

sine_wave = @(f) sin(2*pi*f*time);
input = 0.3 + 0.2 * sine_wave(f1) + 0.1 * sine_wave(f2) + ...
        0.4 * sine_wave(f3) + 0.3 * sine_wave(f4) + 0.4 * sine_wave(f5) + ...
        0.2 * sine_wave(f6);
    
% Normalization
input = input ./ max(abs(input * 32768 / 32767)) * 0.25;

B = B_interp_q15 / 32768;
y = filter(B, 1, input);

H_x = zeros(length(B), 1);

error = zeros(1, length(y));

wn = zeros(1, length(B));
wn(1) = 0;

sum_wn = zeros(1, length(y));

% LNLMS algorithm
eps = 0.1;
for i = 1:length(y)
    H_x = [input(i); H_x(1:end-1)];
    
    error(i) = y(i) - wn * H_x;
    wn = alpha * wn + mu * error(i) * H_x' / (H_x' * H_x + eps);
    sum_wn(i) = sum(wn);
end

expect = error;

figure;
subplot(3, 1, 1);
stairs(time, y);
subplot(3, 1, 2);
stairs(time, error);
subplot(3, 1, 3);
stairs(time, sum_wn);

mkdir lnlms;
fid_in = fopen('lnlms/input_vector.csv', 'w');
fid_expect = fopen('lnlms/expect_vector.csv', 'w');

fprintf(fid_in, "%f\n", input);
fprintf(fid_expect, "%f\n", expect);