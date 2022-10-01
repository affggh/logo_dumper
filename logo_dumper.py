#!/usr/bin/env python3
# Python script by affggh

import os
import struct

class DUMPCFG:
    def __init__(self):
        self.blksz = 0x1<<0xc
        self.headoff = 0x4000
        self.magic = b"LOGO!!!!"
        self.imgnum = 0
        self.imgblkoffs = []
        self.imgblkszs = []

class BMPHEAD(object):
    def __init__(self, buf:bytes=None): # Read bytes buf and use this struct to parse
        if buf == None:
            raise SyntaxError("buf Should be bytes not %s" %type(buf))
        # print(buf)
        self.structstr = "<H6I"
        (
            self.magic,
            self.fsize,
            self.reserved,
            self.hsize,
            self.dib,
            self.width,
            self.height,
        ) = struct.unpack(self.structstr, buf)

class XIAOMI_BLKSTRUCT(object):
    def __init__(self, buf:bytes):
        self.structstr = "2I"
        (
            self.imgoff,
            self.blksz,
        ) = struct.unpack(self.structstr, buf)

class LOGODUMPER(object):
    def __init__(self, img:str, out:str):
        self.out = out
        self.img = img
        self.structstr = "<8s"
        self.cfg = DUMPCFG()
        self.chkimg(img)

    def chkimg(self, img:str):
        if not os.access(img, os.F_OK):
            raise FileNotFoundError(f"{img} does not found!")
        with open(img, 'rb') as f:
            f.seek(self.cfg.headoff, 0)
            self.magic = struct.unpack(
                self.structstr, f.read(struct.calcsize(self.structstr))
            )[0]
            while(True):
                m = XIAOMI_BLKSTRUCT(f.read(8))
                if m.imgoff != 0:
                    # print(blksz<<0xc)
                    self.cfg.imgblkszs.append(m.blksz<<0xc)
                    self.cfg.imgblkoffs.append(m.imgoff<<0xc)
                    self.cfg.imgnum += 1
                else:
                    break
        # print(self.magic)
        if self.magic != b"LOGO!!!!":
            raise TypeError("File does not match xiaomi logo magic!")
        else:
            print("Xiaomi LOGO!!!! format check pass!")
    
    def unpack(self):
        with open(self.img, 'rb') as f:
            print("Unpack:\n"
                  "BMP\tSize\tWidth\tHeight")
            for i in range(self.cfg.imgnum):
                f.seek(self.cfg.imgblkoffs[i], 0)
                bmph = BMPHEAD(f.read(26))
                f.seek(self.cfg.imgblkoffs[i], 0)
                print("%d\t%d\t%d\t%d" %(i ,bmph.fsize, bmph.width, bmph.height))
                with open(os.path.join(self.out, "%d.bmp" %i), 'wb') as o:
                    o.write(f.read(bmph.fsize))
            print("\tDone!")
    
    def repack(self):
        with open(self.out, 'wb') as o:
            off = 0x5
            for i in range(self.cfg.imgnum):
                print("Write BMP [%d.bmp] at offset 0x%X" %(i, off<<0xc))
                with open(os.path.join("pic", "%d.bmp" %i), 'rb') as b:
                    bhead = BMPHEAD(b.read(26))
                    b.seek(0, 0)
                    # print("%x" %off)
                    self.cfg.imgblkszs[i] = (bhead.fsize>>0xc) + 1
                    self.cfg.imgblkoffs[i] = off

                    o.seek(off<<0xc)
                    o.write(b.read(bhead.fsize))

                    off += self.cfg.imgblkszs[i]
            # self.cfg.imgblkoffs[0] = 0x5   # override
            o.seek(self.cfg.headoff)
            o.write(self.magic)
            #print(self.cfg.imgblkoffs)
            #print(self.cfg.imgblkszs)
            for i in range(self.cfg.imgnum):
                o.write(struct.pack("<I", self.cfg.imgblkoffs[i]))
                o.write(struct.pack("<I", self.cfg.imgblkszs[i]))
            print("\tDone!")

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        prog="logo_dumper", 
        description="Dump Xiaomi bmp format logo and repack.",
        )
    parser.add_argument("IMAGE",
        help="Image path, and it must be set.")
    parser.add_argument("FUNC", 
        help="Function, available functions: unpack repack.")
    parser.add_argument("-o, --out", help="Set output dir or image path", dest="out")

    args = parser.parse_args()
    print(f"Function : {args.FUNC}")
    if args.FUNC.lower() == 'unpack':
        if args.out != None:
            if not os.path.isdir(args.out):
                os.makedirs(args.out)
            LOGODUMPER(args.IMAGE, args.out).unpack()
        else:
            if not os.path.isdir("pic"):
                os.mkdir("pic")
            LOGODUMPER(args.IMAGE, "pic").unpack()
    elif args.FUNC.lower() == 'repack':
        if args.out != None:
            LOGODUMPER(args.IMAGE, args.out).repack()
        else:
            LOGODUMPER(args.IMAGE, "new-logo.img").repack()
    else:
        parser.error("Invalid function !")
