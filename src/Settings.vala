using Json;

public class Indicators.SettingUtils {
    //This class is used to manage Settings and settings-file-interaction.

    string settingsDir = GLib.Environment.get_home_dir () + "/.config/indicators/";
    string settingsFile = "indicators.json";
    string settingsIndicators = "indicatorNames.json";
    GLib.File settings_File;
    GLib.File settings_IndicatorNames_File;
    GLib.FileMonitor monitor; //To monitor changes to allIndicators


    private Gee.HashSet<string> namarupaIndicators;
    private Gee.HashSet<string> allIndicatorNames;
    private bool showEmptyNamarupaIndicator;
    public bool isInstalled = true;

    public SettingUtils () {
        namarupaIndicators = new Gee.HashSet<string> ();
        allIndicatorNames = new Gee.HashSet<string> ();
        
        settings_File = File.new_for_commandline_arg(settingsDir + settingsFile);
        settings_IndicatorNames_File = File.new_for_commandline_arg(settingsDir + settingsIndicators);

        if(!settings_File.query_exists () || !settings_IndicatorNames_File.query_exists ()){
            print("Settings files in " + settingsDir + " doesn't exist. Please install community indicators first and restart io.elementary.wingpanel.\n");
            isInstalled = false;
        } else {
            //write_file(settings_File, generate_Json_String());
            get_Settings_from_Json_string(read_file(settings_File));
            allIndicatorNames = getIndicatorNamesFromFile (settings_IndicatorNames_File);
        }

        monitor = settings_IndicatorNames_File.monitor ( //to track directory use .monitor_directory
            GLib.FileMonitorFlags.NONE
        );
        monitor.changed.connect(allIndicatorsFileChanged);
        print("Monitoring: " + settings_IndicatorNames_File.get_path() + "\n");

    }


    private void allIndicatorsFileChanged () {
        print("All indicators file changed. Maybe there is a new Indicator. Reloading list.\n");
        allIndicatorNames = getIndicatorNamesFromFile (settings_IndicatorNames_File);
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

        builder.set_member_name ("showEmptyNamarupaIndicator");
        builder.add_boolean_value (true);
        builder.end_object ();


        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        string str = generator.to_data (null);

        return str;
    }

    private void get_Settings_from_Json_string (string jsonString) {
        Json.Parser parser = new Json.Parser ();
        parser.load_from_data (jsonString, -1);
        Json.Node root = parser.get_root ();

        Json.Array nama_indicator_list = root.get_object ().get_array_member ("namarupaIndicators");
        foreach (var node in nama_indicator_list.get_elements ()){
            print("Namarupa Indicator, got: " + node.get_string () + "\n");
            this.namarupaIndicators.add(node.get_string ());
        }
        showEmptyNamarupaIndicator = root.get_object ().get_boolean_member ("showEmptyNamarupaIndicator");
        
    }

    private Gee.HashSet<string> getIndicatorNamesFromFile (File file) {
        Gee.HashSet<string> allIndicatorNames = new Gee.HashSet<string> ();

        string jsonString = read_file (file);

        Json.Parser parser = new Json.Parser ();
        parser.load_from_data (jsonString, -1);
        Json.Node root = parser.get_root ();

        Json.Array indicator_list = root.get_object ().get_array_member ("allIndicators");
        foreach (var node in indicator_list.get_elements ()){
            //print("all Indicators, got name: " + node.get_string () + "\n");
            allIndicatorNames.add(node.get_string ());
        }
        return allIndicatorNames;
    }

    public Gee.HashSet<string> getAllIndicatorNames (){
        if(allIndicatorNames == null){
            allIndicatorNames = getIndicatorNamesFromFile (settings_IndicatorNames_File);
        }
        return this.allIndicatorNames;
    }

    public Gee.HashSet<string> getNonNamarupaIndicatorNames (){
        Gee.HashSet<string> out = new Gee.HashSet<string> ();
        
        if(allIndicatorNames == null){
            allIndicatorNames = getIndicatorNamesFromFile (settings_IndicatorNames_File);
            
        }
        foreach (string allIn in allIndicatorNames) {
            if(! this.namarupaIndicators.contains(allIn)){
                out.add(allIn);
            }
        }

        return out;
    }  
    public void toggleNamarupaForIndicator (string name) {
        //If name is inside NamarupaIndicators, delete it there, otherwise add it.
        if (getNamarupaIndicatorNames ().contains (name)){
            this.namarupaIndicators.remove (name);
        } else {
            this.namarupaIndicators.add (name);
        }
        updateSettingsFile ();
    }

    private void updateSettingsFile (){
        write_file(settings_File, generate_Json_String());
        settings_updated ();
    }

    public Gee.HashSet<string> getNamarupaIndicatorNames (){
        if (this.namarupaIndicators == null) {
            get_Settings_from_Json_string(read_file(settings_File));
        }
        return this.namarupaIndicators;
    }

    public string getIndicatorPath (){
        return (this.settingsDir + "icons/");
    }
    public bool getShowEmptyNamarupa () {
        return this.showEmptyNamarupaIndicator;
    }

    public signal void settings_updated ();
}