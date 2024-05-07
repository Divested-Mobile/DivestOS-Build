import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Scanner;

public class asb {

    public static void main(String[] args) {
        try {
            Scanner s = new Scanner(System.in);
            ArrayList<String> patchers = new ArrayList<>();
            while (s.hasNextLine()) {
                String line = s.nextLine();
                if(line.trim().length() > 0 && line.contains("github.com")) {
                    String[] lineS = line.split(" ");
                    String url = lineS[0];
                    String project = url.split("/")[4];
                    String id = lineS[1];
                    String comment = "#" + line.split(" #")[1];

                    //Print the folders only
                    //System.out.println(project);

                    //Print the downloader
                    //System.out.println("wget " + url + ".patch" + " -O " + project + "/" + id + ".patch; " + comment);

                    //Print the patcher
                    patchers.add("applyPatch \"$DOS_PATCHES/" + project + "/" + id + ".patch\"; " + comment);
                }
                if(line.equals("COMPLETE")) {
                    break;
                }
            }

            Collections.sort(patchers);
            for(String patcher : patchers) {
                System.out.println(patcher);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
