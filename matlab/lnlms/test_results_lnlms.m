clear;
close all;
clc;

fid1 = fopen('../../tests/test_lnlms/input_vector.csv', 'r');
fid2 = fopen('../../workspace/stm32/stm32-anc/tests/test_lnlms/output_vector.csv', 'r');
fid3 = fopen('../../workspace/stm32/stm32-anc/tests/test_lnlms/expect_vector.csv', 'r');

in      = fscanf(fid1, '%f\n');
out     = fscanf(fid2, '%f\n');
expect  = fscanf(fid3, '%f\n');

error = out - expect;

figure;
stairs(out, 'r');
hold on;
stairs(expect, 'k--');
grid on;
%stairs(error, 'b');
%xlim([0, 1000]);

title('Identification error');
xlabel('step');
ylabel('value');
legend('algorithm in C', 'algorithm in Matlab');
