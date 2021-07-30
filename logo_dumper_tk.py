# 感谢百度和万能网友让我弄出来了个gui界面
# 脚本 by affggh
import os
import sys
import subprocess
import tkinter as tk 
from tkinter.filedialog import *

root = tk.Tk()
filename = tk.StringVar()

def selectFile():
	filepath = askopenfilename()  # 选择打开什么文件，返回文件名
	filename.set(filepath)      # 设置变量filename的值

def extractLogo():
    # cmd = 'cmd.exe d:/start.bat'
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    p = os.system("cmd.exe /c" + "logo_dumper.bat " + "%s " %(filename.get()) + "extract")
    print(p)

def injectLogo():
    # cmd = 'cmd.exe d:/start.bat'
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    p = os.system("cmd.exe /c" + "logo_dumper.bat " + "%s " %(filename.get()) + "inject")
    print(p)

def cmd_test():
    # cmd = 'cmd.exe d:/start.bat'
    os.chdir(os.path.abspath(os.path.dirname(sys.argv[0])))
    p = subprocess.Popen("cmd.exe /c" + "logo_dumper.bat " + "%s " %(filename.get()) + "extract", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    curline = p.stdout.readline()
    while (curline != b''):
        print(curline)
        curline = p.stdout.readline()
    p.wait()
    print(p.returncode)

root.title("logo_dumper by 酷安 affggh")

# 构建“选择文件”这一行的标签、输入框以及启动按钮，同时我们希望当用户选择图片之后能够显示原图的基本信息
tk.Label(root, text='选择文件').grid(row=1, column=0, padx=5, pady=5)
tk.Entry(root, width=30,textvariable=filename).grid(row=1, column=1, padx=5, pady=5)
tk.Button(root, text='选择文件', command=selectFile).grid(row=1, column=2, padx=5, pady=5)

#  
tk.Button(root, text='解析logo镜像', width=24, height=5, relief="solid", command=extractLogo).grid(row=2, column=1, padx=5, pady=5)

tk.Button(root, text='打包logo镜像', width=24, height=5, relief="solid", command=injectLogo).grid(row=3, column=1, padx=5, pady=5)

tk.Label(root, text='帮助：无论是单独解包还是打包\n都要选择官方的logo或splash镜像\n然后运行解包和打包等待一会儿即可\n打包时要注意\n一定要使用同分辨率BMP 24bit格式的图像！').grid(row=4, column=1, padx=5, pady=5)

root.mainloop()