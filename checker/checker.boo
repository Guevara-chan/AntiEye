# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# AntiEye webcam checker v0.03
# Developed in 2018 by Guevara-chan.
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import System
import System.IO
import System.Drawing
import System.Windows.Forms
import System.Text.RegularExpressions
import System.Runtime.CompilerServices

#.{ [Classes]
class CUI():
	static final channels = {"fail": "Red", "success": "Cyan", "launch": "DarkGray", "io": "Yellow",
		"fault": "DarkRed", "meta": "Green"}

	def constructor():
		dbg("")
		log("""# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
			# AntiEye webcam checker v0.03      #
			# Developed in 2018 by V.A. Guevara #
			# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #""".Replace('\t', ''), "meta")

	# --Methods goes here.
	def log(info, channel as string):
		Console.ForegroundColor = Enum.Parse(ConsoleColor, channels[channel])
		print "$info"

	def dbg(info):
		Console.Title = "◢.AntiEye$info.◣"
# -------------------- #
class DirReport():
	dest		= ""
	succfile 	= null
	failfile	= null
	channels	= {}

	def constructor(title as string):
		Directory.CreateDirectory(dest = "$(IO.Path.GetFileName(title))~shots")
		succfile, failfile = (File.CreateText(req("$f.txt")) for f in ('success', 'fail'))
		channels = {"success": succfile, "fail": failfile}

	def echo(info, channel as string):
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
	log		= {info, channel|info = ':I Am Dummy:'; return self}
	dbg		= {info|info = ':I am Error:'; return self}
	tasks	= Collections.Generic.Dictionary[of String, bool]()
	final tension_limit = 15
	reporter as Type

	# --Methods goes here.
	def constructor(ui as duck, storage as Type):
		log			= {info, channel|ui.log(info, channel); return self}
		dbg			= {info|ui.dbg(info); return self}
		reporter	= storage

	def parse(entry as string):
		entry = Regex(" ").Replace(entry, '\n', 1)
		if Regex.Matches(entry, ":").Count == 2 and Regex.Matches(entry, "\n").Count == 1:
			host, port, user, pword = entry.Split(char(':'), char('\n'))
			return Uri("http://$(Uri.EscapeDataString(user)):$(Uri.EscapeDataString(pword))@$host:$port")

	def check(url as Uri, dest as duck):
		frame = WebBrowser(Width: 680, Height: 510, ScriptErrorsSuppressed: true)
		user, password = url.UserInfo.Split(char(':'))
		frame.Navigate("$(url)snapshot.cgi?user=$(user)&pwd=$(password)")
		frame.DocumentCompleted += checker(url, dest)
		log("Launching check for $url", 'launch').tasks.Add(url.ToString(), true)
		return self

	def checker(url as Uri, dest as duck):
		return def(sender as WebBrowser, e):
			return unless tasks.Remove("$url")
			# Error checkup.
			# TO BE DONE !
			# Down checkup.
			if 'res://ieframe.dll/ErrorPageTemplate.css' in sender.DocumentText:
				dest.echo(url, 'fail')
				return log("Unable to load $url", 'fail')
			# Screenshot init.
			using bmp = Bitmap(sender.Width - 20, sender.Height):
				sender.DrawToBitmap(bmp, Rectangle(0, 0, bmp.Width, bmp.Height))
				#try: bmp = bmp.Clone(Rectangle(10, 15, bmp.Width - 30, bmp.Height - 10), bmp.PixelFormat)
				#except ex: print ex

				using out = Graphics.FromImage(bmp):
					login = url.UnescapeDataString(url.UserInfo)
					rect = Rectangle(start = Point(5, 5), out.MeasureString(login, font = Font('Sylfaen', 11)).ToSize())
					rect.Width += 2
					out.FillRectangle(SolidBrush(Color.Black), rect)
					out.DrawRectangle(Pen(forecolor = Color.Coral, 1), rect)
					out.DrawString(login, font, SolidBrush(forecolor), start)
				shot = dest.store(bmp, "$(url.Host)[$(url.Port)].png")
			# Finalization.
			log("$shot was taken from $url", 'success')
			dest.echo(url, 'success')

	def wait(max_tension as int):
		while tension > max_tension: Application.DoEvents()
		return self

	[Extension] static def echo(out as StreamWriter, text as string):
		out.WriteLine(text)
		out.Flush()
		return text

	tension:
		get: return tasks.Count

	feed:
		set:
			try:
				dest = reporter(value)
				log("\nParsing '$value'...", 'io')
				for entry in File.ReadLines(value):
					if (url = parse(entry)): check(url, dest).dbg(" [$tension/$(tension_limit+1)]").wait(tension_limit)
					else: log("Invalid entry encountered: $entry", 'fault')
				wait(0)
			except ex: log("$ex", 'fault')
#.}

# ==Main code==
[STAThread] def Main(argv as (string)):	
	Checker(CUI(), DirReport).feed = (argv[0] if argv.Length else 'feed.txt')
	Threading.Thread.Sleep(3000)