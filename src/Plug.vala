

public class Indicators.Plug : Switchboard.Plug {
    private Gtk.Grid main_grid;

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
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            //Build main Grid
            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            var lbl = new Gtk.Label ("Test Plug");
            lbl.set_text ("Test Plug");
            main_grid.attach(lbl, 0, 0);
            main_grid.show ();
            lbl.show ();

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