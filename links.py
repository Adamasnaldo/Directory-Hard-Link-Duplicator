import filecmp
import os
import shutil
from tkinter.filedialog import askdirectory
from tkinter.messagebox import askyesnocancel

def askFolder(msg: str):
    folder = askdirectory(title = msg, initialdir = ".")
    if not folder:
        print("No folder selected...")
        exit(1)

    return folder

def link_if_same(src: str, dst: str):
    if not os.path.isfile(dst):
##        print(f"{dst} does not exist!")
        return

##    stat_src = os.stat(src)
##    stat_dst = os.stat(dst)
##    if stat_src.st_nlink != 1:
##        print(f"Source {src} has {stat_src.st_nlink} links!")
##    if stat_dst.st_nlink != 1:
##        print(f"Destination {dst} has {stat_dst.st_nlink} links!")
##
##    if stat_src.st_ino == stat_dst.st_ino:
##        return
##        print(dst, "is hard link! It has", stat_src.st_nlink, stat_dst.st_nlink, "links !")
##
##    return

    basename = os.path.basename(dst)
    if not filecmp.cmp(src, dst, shallow=False):
        print(f"{basename} is different on source and destination!")
        return

    print(f"{basename} is same, linking!")
    os.remove(dst)
    os.link(src, dst)

def main():
    copy_from = askFolder("Select the directory to copy from.")
    copy_to = askFolder("Select the directory to copy to.")
    same_files_only = askyesnocancel(title="Same files only?", message="Do you want to hard link only the same files? This will replace every file in the destination with a hardlink to the source, if it exists in both and is the same in both.")
    if same_files_only is None:
        print("Cancelled...")
        exit(1)

    copy_function = link_if_same if same_files_only is True else os.link

    filecmp.clear_cache()
    shutil.copytree(copy_from, copy_to, copy_function=copy_function, dirs_exist_ok=True)


if __name__ == "__main__":
    main()
