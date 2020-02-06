import os
import glob

folderPath = os.getcwd()

outputfolderPath = folderPath + "/cl/" #cl subfolder will be created if it doesn't exist
os.makedirs(os.path.dirname(outputfolderPath), exist_ok=True)
for i in glob.glob(folderPath + "/*.txt"):
    with open(i) as rawfile, open(outputfolderPath + os.path.basename(i)[:-4] + "_cl.txt", "w") as cleanfile:

        for line in rawfile:
            #I'm so sorry
            cleanfile.write(line.replace("How long is the imaging session (answer in seconds; recording will start after pressing ENTER)?", "").replace("How long is the imaging session (answer in seconds and press ENTER; time from TTL HIGH to end of the aqusition)?", "").replace(", array('B', [", "").replace("])", "").replace(",", ""))