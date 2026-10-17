using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using System.Threading.Tasks;

namespace SHACKBuilderHub
{
    public partial class MainHub : Form
    {
        string whapPath = @"";
        string rocketPath = @"";
        string wpPath = @"C:\\Users\\Admin\\AppData\\Local\\Microsoft\\WindowsApps\\studio.exe";
        string hubRoot = @"C:\BanglaHost\BuilderHub";

        public MainHub()
        {
            this.Text = "1989SHACK Unified Builder Hub - Deep Root Edition";
            this.Width = 1300; this.Height = 800;
            this.BackColor = System.Drawing.Color.FromArgb(2, 10, 26);
            InitializeHub();
        }

        void InitializeHub()
        {
            TabControl tabs = new TabControl(); tabs.Dock = DockStyle.Fill;

            // TAB 1: Builder Selector
            TabPage tabBuild = new TabPage("🚀 BUILDER");
            Button btnRocket = new Button(){Text="Open RocketCake - Responsive Designer", Width=400, Height=80, Top=20, Left=20, BackColor=System.Drawing.Color.Orange};
            btnRocket.Click += (s,e)=>{ LaunchApp(rocketPath, "RocketCake Project"); };
            Button btnWP = new Button(){Text="Open WordPress Studio - Create WP Site", Width=400, Height=80, Top=120, Left=20, BackColor=System.Drawing.Color.FromArgb(37,211,102)};
            btnWP.Click += (s,e)=>{ LaunchApp(wpPath, "WordPress Site"); };
            Button btnAI = new Button(){Text="🤖 AI Builder - Type prompt & build", Width=400, Height=80, Top=220, Left=20, BackColor=System.Drawing.Color.FromArgb(41,182,246)};
            btnAI.Click += (s,e)=>{ MessageBox.Show("AI Builder: Type 'Build restaurant site for Monrovia with menu, contact, map' - Coming in Flutter app!"); };
            tabBuild.Controls.AddRange(new Control[]{btnRocket, btnWP, btnAI});

            // TAB 2: WHAP cPanel Hub 8881-8887
            TabPage tabCpanel = new TabPage("💾 cPANEL 8881-8887");
            ListView lvPorts = new ListView(){View=View.Details, Width=800, Height=400, Top=20, Left=20};
            lvPorts.Columns.Add("Port",100); lvPorts.Columns.Add("Status",100); lvPorts.Columns.Add("Customers",100); lvPorts.Columns.Add("Action",200);
            for(int p=8881;p<=8887;p++){
                var item = new ListViewItem(new string[]{p.ToString(), "● Online", "0", "Manage"});
                lvPorts.Items.Add(item);
            }
            Button btnManage = new Button(){Text="Open WHAP Hosting Manager", Width=300, Height=50, Top=450, Left=20, BackColor=System.Drawing.Color.FromArgb(255,140,0)};
            btnManage.Click += (s,e)=>{ LaunchApp(whapPath, "cPanel Manager"); };
            tabCpanel.Controls.AddRange(new Control[]{lvPorts, btnManage});

            // TAB 3: Deploy Center - One Click Publish
            TabPage tabDeploy = new TabPage("🌍 DEPLOY CENTER");
            Label lbl = new Label(){Text="One-Click Deploy to Global Edge (30ms Liberia) - Select project then PUBLISH", Width=600, Top=20, Left=20, ForeColor=System.Drawing.Color.White};
            Button btnPublish = new Button(){Text="🚀 PUBLISH TO LIVE - 1989SHACK Global Edge", Width=500, Height=100, Top=60, Left=20, BackColor=System.Drawing.Color.FromArgb(0,200,83), Font=new System.Drawing.Font("Arial",16,System.Drawing.FontStyle.Bold)};
            btnPublish.Click += async (s,e)=>{
                MessageBox.Show("Deep Root Deploy: \n1. Building site...\n2. Uploading to least loaded cPanel port (8881-8887)...\n3. Purging Cloudflare cache...\n4. Site live at 30ms!\n\nFile: C:\\BanglaHost\\BuilderHub\\deploy\\deploy.ps1 running...");
                await Task.Run(()=>{ Process.Start("powershell.exe", $"-File {hubRoot}\\deploy\\deploy.ps1"); });
            };
            tabDeploy.Controls.AddRange(new Control[]{lbl, btnPublish});

            // TAB 4: MoMo Billing
            TabPage tabMoMo = new TabPage("💰 MOMO BILLING");
            Label lblMoMo = new Label(){Text="Mobile Money Auto-activation: Customer pays L\ → Account auto-creates on 8881-8887\n\nYour MTN Merchant: 088XXXXXX - Money goes to YOUR account\n\nStatus: Webhook active at /api/momo-webhook.php", Width=700, Height=100, Top=20, Left=20, ForeColor=System.Drawing.Color.White};
            tabMoMo.Controls.Add(lblMoMo);

            tabs.TabPages.AddRange(new TabPage[]{tabBuild, tabCpanel, tabDeploy, tabMoMo});
            this.Controls.Add(tabs);
        }

        void LaunchApp(string path, string name)
        {
            if(File.Exists(path)){
                try{ Process.Start(path); Log($"Launched {name}: {path}"); }
                catch(Exception ex){ MessageBox.Show($"Could not launch {name}: {ex.Message}\nPath: {path}"); }
            } else {
                // If exe not found, open folder to select
                OpenFileDialog dlg = new OpenFileDialog(){Filter="EXE files|*.exe", Title=$"Select {name} EXE"};
                if(dlg.ShowDialog()==DialogResult.OK){
                    Process.Start(dlg.FileName);
                    // Save path
                    File.WriteAllText(hubRoot+"\\bin\\"+name.Replace(" ","")+".path", dlg.FileName);
                }
            }
        }
        void Log(string msg){ File.AppendAllText(hubRoot+"\\logs\\hub.log", DateTime.Now+" - "+msg+"\n"); }

        [STAThread]
        static void Main(){ Application.EnableVisualStyles(); Application.Run(new MainHub()); }
    }
}
