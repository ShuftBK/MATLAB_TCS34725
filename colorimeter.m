%% colorimeter
clearvars;close all;
%%

%% Initialize I2C device
a = arduino('COM9','Mega2560','Libraries','I2C');   % PC1
% a = arduino('COM3','Mega2560','Libraries','I2C'); % PC2
bus = scanI2CBus(a);    % TCS34725 Address: 0x29
dev = device(a,'I2CAddress',bus{1});
readRegister(dev,'0x12',1,'uint8')

%% Get TCS34725 id
Idregister = bitor(0b10000000,0x12,'uint8');
write(dev,Idregister,"uint8");
id = read(dev, 1,"uint8");
fprintf('TCS34725 ID: 0x%x\n', id);   % 0x44 = TCS34721 or TCS34725
%% Set RGBC Time
CRGBTimeregister = bitor(0b10000000,0x01,'uint8');
write(dev,CRGBTimeregister,'uint8');
write(dev,0x00,'uint8')% 256Cycle
% read(dev,1,"uint8")
%% Set Control Register
Controlregister = bitor(0b10000000,0x0F,'uint8');
write(dev,Controlregister,'uint8');
write(dev,0b00000010,'uint8')% 16xGAIN
% read(dev,1,"uint8")
%% Set Control Register
Enableregister = bitor(0b10000000,0x00,'uint8');
write(dev,Enableregister,'uint8');
write(dev,0b00000011,'uint8');
% read(dev,1,"uint8")
%% wait timer
pause(1);

%% Get Status
Statusregister = bitor(0b10000000,0x13,'uint8');
write(dev,Statusregister,"uint8");
Status = read(dev, 1, "uint8");

%% Initialize figure plot area
figure();
box on;
area1 = fill([0 1 1 0],[0 0 1 1], 'k');  % make black area
ax = gca;
pbaspect([1 1 1]);
ax.XTickLabel = cell(size(ax.XTickLabel));
ax.YTickLabel = cell(size(ax.YTickLabel));
ax.TickLength= [0 0];

figure();
box on;
area2 = fill([0 1 1 0],[0 0 1 1], 'k');  % make black area
ax = gca;
pbaspect([1 1 1]);
ax.XTickLabel = cell(size(ax.XTickLabel));
ax.YTickLabel = cell(size(ax.YTickLabel));
ax.TickLength= [0 0];

%% Get ColorData
while 1
    Dataregister = bitor(0b10100000,0x14,'uint8');
    write(dev,Dataregister,'uint8');
    CRGB = read(dev, 8, "uint8");
    C = bitor(CRGB(1),bitshift(CRGB(2),8,'uint16'),'uint16');
    R = bitor(CRGB(3),bitshift(CRGB(4),8,'uint16'),'uint16');
    G = bitor(CRGB(5),bitshift(CRGB(6),8,'uint16'),'uint16');
    B = bitor(CRGB(7),bitshift(CRGB(8),8,'uint16'),'uint16');
    r = R / C * 255.0;
    g = G / C * 255.0;
    b = B / C * 255.0;
    %     fill([0 1 1 0],[0 0 1 1],[R/65535 G/65535 B/65535]);
    fprintf('C: %6d, R: %6d, G: %6d, B: %6d\n',C,R,G,B);
    %     fprintf('C(8): %3d, R(8): %d, G(8): %d, B(8): %d\n',C/256,R/256,G/256,B/256);
    set(area1,'FaceColor',[R/65535 G/65535 B/65535]);
    set(area2,'FaceColor',[r/255 g/255 b/255]);
    pause(.25);
end
