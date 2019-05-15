#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

"""
Created by Michael Morken, April 2015.
Revised by Ellie Tan, May 2019.

With Anaconda, tkinter should be installed by default. Only pyserial module needs
to be installed.
"""

import tkinter as Tkinter # old module was named Tkinter
import tkinter.messagebox as tkMessageBox # old module was tkMessageBox
import serial
import time

ser = ''

class simpleapp_tk(Tkinter.Tk):
    def __init__(self,parent):
        Tkinter.Tk.__init__(self,parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        self.grid()

        #Setting up the arduino Connect Part
        arduinoConnect = Tkinter.Button(self,text='Connect!',command=self.arduinoConnect)
        arduinoConnect.grid(column=1,row=0,columnspan=1,sticky='EW')

        arduinoLabel = Tkinter.Label(self,text='Connect to the Arduino: ')
        arduinoLabel.grid(column=0,row=0,columnspan=1,sticky='EW')
    
        self.arduinoConnectionVariable = Tkinter.StringVar()                   
        arduinoConnectStatus = Tkinter.Label(self,textvariable = self.arduinoConnectionVariable,anchor='w') #Dummy Variable
        arduinoConnectStatus.grid(column=2,row=0,columnspan=1,sticky='EW')
        self.arduinoConnectionVariable.set(u"Not Connected")

        self.arduinoSerialPortVariable = Tkinter.StringVar()
        arduinoSerialPort = Tkinter.Label(self,textvariable = self.arduinoSerialPortVariable,anchor='w')
        arduinoSerialPort.grid(column=0,row=1,columnspan=3,sticky='EW')
        

        #Setting Up the Grating Select Part
        selectGratingLabel = Tkinter.Label(self,text = 'Select One of The Available Gratings:') #Fixed Select Grating Label
        selectGratingLabel.grid(column=0,row=2,columnspan=3,sticky='EW')


        button1800 = Tkinter.Button(self,text = '1800', command = self.grating1800)
        button1800.grid(column=0,row=3,columnspan=1,sticky='EW')

        button150 = Tkinter.Button(self,text = '150', command = self.grating150)
        button150.grid(column=1,row=3,columnspan=1,sticky='EW')

        button3600 = Tkinter.Button(self,text = '3600', command = self.grating3600)
        button3600.grid(column=2,row=3,columnspan=1,sticky='EW') #Add all the functions for the buttons

        self.gratingStatusVariable = Tkinter.StringVar()
        gratingStatusLabel = Tkinter.Label(self,textvariable=self.gratingStatusVariable)
        gratingStatusLabel.grid(column=0,row=4,columnspan=3,sticky='EW') #Remember to make functions to change label
        self.gratingStatusVariable.set(u"No Grating Selected")
        '''
        #Preserving old code from the GUI
        button = Tkinter.Button(self,text=u"Click me !",
                                command=self.OnButtonClick)
        button.grid(column=2,row=10)

        self.labelVariable = Tkinter.StringVar()
        label = Tkinter.Label(self,textvariable=self.labelVariable,
                              anchor="w",fg="white",bg="blue")
        label.grid(column=0,row=10,columnspan=1,sticky='EW')
        self.labelVariable.set(u"Hello !")
        '''

        #Wavelength Enter Box
        self.wavelengthEntry = Tkinter.StringVar()
        self.wavelengthBox = Tkinter.Entry(self,textvariable=self.wavelengthEntry)
        self.wavelengthBox.grid(column=1,row=8,columnspan=1,sticky='EW')
        self.wavelengthBox.bind("<Return>", self.wavelengthEnter)
        self.wavelengthEntry.set(u"Ex. 545 ")

        enterWavelengthLabel = Tkinter.Label(self,text='Type in the desired wavelength and Press Enter')
        enterWavelengthLabel.grid(column=0,row=7,columnspan=3,sticky='EW')

        changeLambda = Tkinter.Button(self,text = u"Change Wavelength",command=self.changeWavelength)
        changeLambda.grid(column=0,row=8,columnspan=1,sticky='EW')

        changeGrating = Tkinter.Button(text="Change Grating",command=self.changeGrating)
        changeGrating.grid(column=2,row=8,columnspan=1,sticky='EW')

        self.wavelengthStatusVariable = Tkinter.StringVar()
        wavelengthStatusLabel = Tkinter.Label(self,textvariable=self.wavelengthStatusVariable)
        wavelengthStatusLabel.grid(column=0,row=9,columnspan=3,sticky='EW')
        self.wavelengthStatusVariable.set(u"No Wavelength Selected")
        
        #Setting up the Window
        self.grid_columnconfigure(0,weight=1)
        self.resizable(True,False)
        self.update()
        self.geometry(self.geometry())       
        self.wavelengthBox.focus_set()
        self.wavelengthBox.selection_range(0, Tkinter.END)
        
    #Setting up the Functions
        '''
    def OnButtonClick(self):
        self.labelVariable.set( self.wavelengthEntry.get()+" (You clicked the button)" )
        self.wavelengthBox.focus_set()
        self.wavelengthBox.selection_range(0, Tkinter.END)
        '''


    #Changing wavelength Functions
    def wavelengthEnter(self,event):
        try:
            self.wavelengthStatusVariable.set("You Selected a Wavelength of " + self.wavelengthEntry.get() + " nm")
            self.wavelengthBox.focus_set()
            self.wavelengthBox.selection_range(0, Tkinter.END)
            global ser
            ser.write(str.encode(self.wavelengthEntry.get()))
        except:
            tkMessageBox.showwarning("Not Connected!", "E1: Please check connection to arduino and try again!")
            self.wavelengthStatusVariable.set(u"No Wavelength Selected")

    def changeWavelength(self):
        try:
            self.wavelengthStatusVariable.set("Now Enter a new value for Wavelength")
            self.wavelengthEntry.set(u"Enter a new wavelength")
            self.wavelengthBox.focus_set()
            self.wavelengthBox.selection_range(0, Tkinter.END)
            global ser
            ser.write(str.encode('N'))
        except:
            tkMessageBox.showwarning("Not Connected!", "E2: Please check connection to arduino and try again!")
            self.wavelengthStatusVariable.set(u"No Wavelength Selected")

    def changeGrating(self):
        try:
            self.wavelengthStatusVariable.set("Select a new Grating")
            self.wavelengthEntry.set(u"Enter a new wavelength")
            self.wavelengthBox.focus_set()
            self.wavelengthBox.selection_range(0, Tkinter.END)
            global ser
            ser.write(str.encode('Y'))
        except:
            tkMessageBox.showwarning("Not Connected!", "E3: Please check connection to arduino and try again!")
            self.wavelengthStatusVariable.set(u"No Wavelength Selected")
        
    def callback(self):
        pass
    
    
    
    #Arduino Connection Function
    def arduinoConnect(self):
        locations = ['  COM1','  COM2','  COM3','COM4','COM5','COM6','COM7','COM8','COM9','COM10',
                     '/dev/tty.usbmodemfa131', '/dev/cu.usbmodemfa131', '/dev/tty.usbmodemfd121', '/dev/cu.usbmodemfd121'] #All Known Arduino Comports
        dummyVariable = 0
        while True:
            for device in locations:
                try:
                    global ser
                    ser = serial.Serial(device,9600)
                    self.arduinoConnectionVariable.set("Connected")
                    self.arduinoSerialPortVariable.set("Serial Port: " + device)
                    dummyVariable=1
                    break
                except:
                    self.arduinoConnectionVariable.set("Failed on "+device)
                    self.arduinoSerialPortVariable.set("Failed to Connect to a Serial Device")
            if dummyVariable==1:
                break
            else:
                self.arduinoConnectionVariable.set("Not Connected")
                tkMessageBox.showwarning("Not Connected!", "E4: Please check connection to arduino and try again!")
                ser=''
                break
            
            
            
    #Grating Functions
    def grating1800(self):
        try:
            self.gratingStatusVariable.set("Selecting the 1800 grating")
            self.wavelengthStatusVariable.set("Now Enter a New Value for Wavelength")
            global ser
            ser.write(str.encode('1800'))
            #time.sleep(60)
        except:
            tkMessageBox.showwarning("Not Connected!", "E5: Please check connection to arduino and try again!")
            self.gratingStatusVariable.set("No Grating Selected")
            
    def grating150(self):
        try:
            self.gratingStatusVariable.set("Selecting the 150 grating")
            self.wavelengthStatusVariable.set("Now Enter a New Value for Wavelength")
            global ser
            ser.write(str.encode('150'))
            #time.sleep(60)
        except:
            tkMessageBox.showwarning("Not Connected!", "E6: Please check connection to arduino and try again!")
            self.gratingStatusVariable.set("No Grating Selected")

    def grating3600(self):
        try:
            self.gratingStatusVariable.set("Selecting the 3600 grating")
            self.wavelengthStatusVariable.set("Now Enter a New Value for Wavelength")
            global ser
            ser.write(str.encode('3600'))
 #           time.sleep(60)
        except:
            tkMessageBox.showwarning("Not Connected!", "E7: Please check connection to arduino and try again!")
            self.gratingStatusVariable.set("No Grating Selected")

    

        
if __name__ == "__main__":
    app = simpleapp_tk(None)
    app.title('MorkSpec')
    app.mainloop()
