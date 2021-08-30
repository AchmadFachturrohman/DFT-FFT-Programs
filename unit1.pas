unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, TAGraph, TASeries, Math, Menus;

type
  myArray = array [-10000..10000] of real;

  { TForm1 }

  TForm1 = class(TForm)
    Plot: TButton;
    Button2: TButton;
    Button3: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart2: TChart;
    Chart2BarSeries1: TBarSeries;
    Chart3: TChart;
    Chart3LineSeries1: TLineSeries;
    Chart4: TChart;
    Chart4BarSeries1: TBarSeries;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    procedure PlotClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    function myFFT(inp: myArray):myArray;
    function ubah(x: myArray):myArray;
    function balik(inp: integer):integer;
    function jum_sin (y: real):real;
    function s_cos (y,z: real):real;
    function s_sin (y,z: real):real;
  public

  end;

var
  Form1: TForm1;
  ampli1,ampli2,ampli3,frek1,frek2,frek3,frek_s,jmlh_data,i,j: integer;
  idft,rei_sig,imi_sig,re_sig,im_sig,dft,signal,h_fft: myArray;

implementation

{$R *.lfm}

{ TForm1 }
function TForm1.jum_sin (y: real):real;
var
  x: real;
begin
  x      := (ampli1*sin(2*pi*frek1*y/frek_s)) + (ampli2*sin(2*pi*frek2*y/frek_s)) + (ampli3*sin(2*pi*frek3*y/frek_s));
  result := x;
end;

function TForm1.s_cos (y,z: real):real;
var
  x: real;
begin
  x      := cos(2*pi*y*z/jmlh_data);
  result := x;
end;

function TForm1.s_sin (y,z: real):real;
var
  x: real;
begin
  x      := sin(2*pi*y*z/jmlh_data);
  result := x;
end;

function TForm1.myFFT(inp: myArray):myArray;
var
  p,q: array[0..10000,0..1] of real;
  zp,i,iterasi,k,index,grup: integer;
  x_real,x_im,m :real;
  temp: myArray;
begin
  zp := round(power(2,(trunc(log2(jmlh_data))+1)));
  for i:=jmlh_data to zp-1 do
  begin
    signal[i]:=0;
  end;
  jmlh_data := zp;

  for i:=0 to jmlh_data-1 do
  begin
    p[i,0] := inp[i];
    p[i,1] := 0;
  end;

  for iterasi:=1 to round(log2(zp)) do
  begin
    index := 0;
    grup  := trunc(power(2,iterasi-1)); //mengelompokkan ganjil genap setelah iterasi
    for i:= 1 to grup do
    begin
      for k:=1 to jmlh_data div(2*grup) do
      begin
      m:= (k-1)*grup;
      q[index,0] := p[index,0] + p[index + jmlh_data div (2*grup),0];
      q[index,1] := p[index,1] + p[index + jmlh_data div (2*grup),1];

      x_real := p[index,0] - p[index + jmlh_data div (2*grup),0];
      x_im   := p[index,1] - p[index + jmlh_data div (2*grup),1];
      q[index + jmlh_data div(2*grup),0] := x_real*s_cos(1,m) + x_im*s_sin(1,m);
      q[index + jmlh_data div(2*grup),1] := x_im*s_cos(1,m)   - x_real*s_sin(1,m);

      inc(index);
      end;
      index := index + jmlh_data div (2*grup); //untuk pergantian grup
    end;
    p := q;
  end;

  for i:=0 to jmlh_data do
  begin
    temp[i] := sqrt(sqr(q[i,0]) + sqr(q[i,1]))/jmlh_data;
  end;
  myFFT := ubah(temp);
end;

function TForm1.ubah(x: myArray):myArray;
var
  i: integer;
  temp: myArray;
begin
  for i:=0 to jmlh_data do
  begin
    temp[i]:= x[balik(i)];
  end;
  ubah := temp;
end;

function TForm1.balik(inp: integer):integer;
var
  n,temp: integer;
begin
  temp := 0;
  n := inp;
  for i:=round(log2(jmlh_data)) downto 1 do
  begin
    temp := temp + trunc(power(2,i-1))*(n mod 2);
    n := n div 2;
  end;
  balik := temp;
end;

procedure TForm1.PlotClick(Sender: TObject);
begin
  ampli1   := strtoint(Edit1.Text);
  ampli2   := strtoint(Edit2.Text);
  ampli3   := strtoint(Edit3.Text);
  frek1    := strtoint(Edit4.Text);
  frek2    := strtoint(Edit5.Text);
  frek3    := strtoint(Edit6.Text);
  frek_s   := strtoint(Edit8.Text);
  jmlh_data:= strtoint(Edit7.Text);

  if RadioButton1.Checked = true then
  begin
    Chart1LineSeries1.Clear;
    signal[i] := 0;
    for i:=0 to jmlh_data do
    begin
      signal[i]:= jum_sin(i);
      Chart1LineSeries1.AddXY(i,signal[i]);
    end;
  end;

  if RadioButton2.Checked = true then
  begin
    Chart2BarSeries1.Clear;
    for i:=0 to jmlh_data-1 do
    begin
      re_sig[i] := 0;
      im_sig[i] := 0;
      for j:=0 to jmlh_data-1 do
      begin
        re_sig[i] := re_sig[i] + signal[j] * s_cos(i,j);
        im_sig[i] := im_sig[i] - signal[j] * s_sin(i,j);
      end;
      dft[i] := sqrt(sqr(re_sig[i]) + sqr(im_sig[i]))/jmlh_data;
      Chart2BarSeries1.AddXY(i*frek_s/jmlh_data,dft[i]);
    end;
  end;

  if RadioButton3.Checked = true then
  begin
    Chart3LineSeries1.Clear;
    for i:=0 to jmlh_data-1 do
    begin
      rei_sig[i] := 0;
      imi_sig[i] := 0;
      for j:=0 to jmlh_data-1 do
      begin
        rei_sig [i]:= rei_sig[i] + re_sig[j] * s_cos(i,j);
        imi_sig [i]:= imi_sig[i] + im_sig[j] * s_sin(i,j);
      end;
      idft[i]:= rei_sig[i] - imi_sig[i];
      Chart3LineSeries1.AddXY(i,idft[i]/jmlh_data);
    end;
  end;

  if RadioButton4.Checked = true then
  begin
    Chart4BarSeries1.Clear;
    h_fft := myFFT(signal);
    for i:=0 to (jmlh_data) do
      Chart4BarSeries1.AddXY(i*frek_s/jmlh_data,h_fft[i]);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Chart1LineSeries1.Clear;
  Chart2BarSeries1.Clear;
  Chart3LineSeries1.Clear;
  Chart4BarSeries1.Clear;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.

