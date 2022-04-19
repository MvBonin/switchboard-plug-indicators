using Json;

public class Indicators.SettingUtils {
    //This class is used to manage Settings and settings-file-interaction.

    string settingsDir = GLib.Environment.get_home_dir () + "/.config/indicators/";
    string settingsFile = "indicators.json";
    GLib.File settings_File;

    private Gee.HashSet<string> namarupaIndicators;
    private bool showEmptyNamarupa;
    public bool isInstalled = true;

    public SettingUtils () {
        namarupaIndicators = new Gee.HashSet<string> ();
        namarupaIndicators.add("ulauncher");
        namarupaIndicators.add("Nextcloud");
        settings_File = File.new_for_commandline_arg(settingsDir + settingsFile);
        if(!settings_File.query_exists ()){
            print("Settings file " + settings_File.get_path () + " doesn't exists. Please install community indicators first.\n");
            isInstalled = false;
        } else {
            print(read_file(settings_File));
            write_file(settings_File, generate_Json_String());
        }

        
    }



    private string read_file(File file) {
        string output;
        try {

            GLib.FileUtils.get_contents(file.get_path (), out output);

        } catch (Error e) {
            error ("%s", e.message);
        }

        return output;
    }

    private void write_file(File file, string content) {
        try {

            GLib.FileUtils.set_contents(file.get_path (), content);

        } catch (Error e) {
            error ("%s", e.message);
        }
    }

    private string generate_Json_String () {
        Json.Builder builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("namarupaIndicators");
        builder.begin_array ();
        foreach (string s in namarupaIndicators) {
            builder.add_string_value (s);
        }
        builder.end_array ();

        /*builder.set_member_name ("defaultIndicatorsPlace");
        builder.add_boolean_value (true);
        builder.end_object ();*/

        builder.set_member_name ("showEmptyNamarupa");
        builder.add_boolean_value (true);
        builder.end_object ();


        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        string str = generator.to_data (null);

        return str;
    }


}