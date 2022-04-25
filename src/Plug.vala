

public class Indicators.Plug : Switchboard.Plug {
    private Gtk.Grid main_grid;
    private SettingUtils? settings_util;
    private Gee.HashSet<string> allIndicatorNames;
    private Gee.HashSet<string> namarupaIndicatorNames;
    
    private Gtk.Box nonNamarupaIconsBox;
    private Gtk.Box namarupaIconsBox;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("indicators", null);

        Object (
            category: Category.PERSONAL,
            code_name: "com.github.mvbonin.switchboard-plug-indicators",
            display_name: "Indicators",
            description: "Change community-indicators settings.",
            icon: "view-more-horizontal-symbolic",
            supported_settings: settings
        );

        settings_util = new SettingUtils ();
        settings_util.settings_updated.connect (update_hbox_widgets);
        
    }
    private Gtk.Box? createHBox (Gee.HashSet<string> strings) {
        
        Gtk.Box hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        hbox.set_homogeneous (true);
        
        foreach (var name in strings) {

            Gtk.Button but = new Gtk.Button();
            GLib.File file = File.new_for_commandline_arg ( settings_util.getIndicatorPath () + name + ".png" );
            if(file.query_exists ()) {
                Gdk.Pixbuf pix = new Gdk.Pixbuf.from_file_at_scale (file.get_path () , 16, 16, true);
            

                but.set_image (new Gtk.Image.from_pixbuf(pix));
                but.set_always_show_image (true);
                but.show ();
                but.clicked.connect (() => {
                    settings_util.toggleNamarupaForIndicator(name);
                });

                hbox.add (but);
            }
            

        }
        
        hbox.show ();
        return hbox;
    }
    private void update_hbox_widgets () {

        if(settings_util.isInstalled ){
            if (nonNamarupaIconsBox != null){
                nonNamarupaIconsBox.destroy();
                nonNamarupaIconsBox = null;
            }
            if (namarupaIconsBox != null){
                namarupaIconsBox.destroy();
                namarupaIconsBox = null;
            }

            nonNamarupaIconsBox = createHBox (settings_util.getNonNamarupaIndicatorNames ()); 
            main_grid.attach(nonNamarupaIconsBox , 0, 1);
            nonNamarupaIconsBox.show();

            namarupaIconsBox = createHBox (settings_util.getNamarupaIndicatorNames ());
                
            main_grid.attach(namarupaIconsBox , 0, 4);
            namarupaIconsBox.show();
        }

    }
    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            //Build main Grid
            main_grid = new Gtk.Grid () {
                row_spacing = 12,
                margin = 30,
                halign = Gtk.Align.CENTER
            };

            if ( !settings_util.isInstalled ){
                var lbl = new Gtk.Label (null);
                lbl.set_markup ("<span size=\"larger\">Please install community indicators first and restart io.elementary.wingpanel or the machine.</span>");
                main_grid.attach(lbl, 0, 0);
                lbl.show ();
                main_grid.show ();
            } else {
                var lbl = new Gtk.Label (null);
                lbl.set_markup ("<span size=\"larger\">Indicators, that appear directly on wingpanel</span>");
                main_grid.attach(lbl, 0, 0);
                lbl.show ();

                
                main_grid.attach (new Gtk.Separator(Gtk.Orientation.HORIZONTAL), 0, 2);

                var lbl2 = new Gtk.Label (null);
                lbl2.set_markup ("<span size=\"larger\">Indicators, that appear in ... menu</span>");
                main_grid.attach(lbl2, 0, 3);
                lbl2.show ();

                var lbl3 = new Gtk.Label (null);
                lbl3.set_markup ("<span size=\"smaller\">Click on the Indicators to change placement.</span>");
                main_grid.attach(lbl3, 0, 5);
                lbl3.show ();


                update_hbox_widgets ();

                main_grid.show ();
            }
        }

        return main_grid;
    }



    public override void search_callback (string location) {
        /*switch (location) {
            case OPERATING_SYSTEM:
            case HARDWARE:
            case FIRMWARE:
                stack.set_visible_child_name (location);
                break;
            default:
                stack.set_visible_child_name (OPERATING_SYSTEM);
                break;
        }*/
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );

        search_results.set ("%s → %s".printf (display_name, "VON"), "ZU");

        return search_results;
    }


    public override void shown () {
    }
    public override void hidden () {
    }
}

public Switchboard.Plug get_plug (Module module){
    debug ("Activating Community Indicators-Plug");
    var plug = new Indicators.Plug ();
    return plug;
}