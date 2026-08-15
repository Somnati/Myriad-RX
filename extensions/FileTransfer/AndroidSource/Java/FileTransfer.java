package ${YYAndroidPackageName};

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.String;

import ${YYAndroidPackageName}.R;
import com.yoyogames.runner.RunnerJNILib;

// SAF (storage access framework) save transfer: lets the player pick a
// real location (Downloads, Drive, ...) to write or read the savefile,
// bypassing the clipboard size limit that truncated big myriad saves.
// results come back through the Async - Social event as
//   type = "filetransfer_export" { success }
//   type = "filetransfer_import" { success, content }
public class FileTransfer extends ExtensionBase {

	private static final int REQ_EXPORT = 7710;
	private static final int REQ_IMPORT = 7711;
	private static final int EVENT_OTHER_SOCIAL = 70;

	private String m_pendingExport = "";

	// open the system "save as" dialog; content is written once the
	// player picks a destination
	public double Export(String filename, String content) {
		try {
			m_pendingExport = content;
			Intent i = new Intent(Intent.ACTION_CREATE_DOCUMENT);
			i.addCategory(Intent.CATEGORY_OPENABLE);
			i.setType("text/plain");
			i.putExtra(Intent.EXTRA_TITLE, filename);
			RunnerActivity.CurrentActivity.startActivityForResult(i, REQ_EXPORT);
			return 0;
		}
		catch (Exception e) {
			Log.i("yoyo", "FileTransfer export intent failed: " + e.toString());
			return -1;
		}
	}

	// open the system file picker; the chosen file's text arrives in
	// the async event
	public double Import() {
		try {
			Intent i = new Intent(Intent.ACTION_OPEN_DOCUMENT);
			i.addCategory(Intent.CATEGORY_OPENABLE);
			i.setType("*/*");
			RunnerActivity.CurrentActivity.startActivityForResult(i, REQ_IMPORT);
			return 0;
		}
		catch (Exception e) {
			Log.i("yoyo", "FileTransfer import intent failed: " + e.toString());
			return -1;
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {

		if (requestCode == REQ_EXPORT) {
			boolean ok = false;
			if (resultCode == Activity.RESULT_OK && data != null) {
				try {
					Uri uri = data.getData();
					OutputStream os = RunnerActivity.CurrentActivity
						.getContentResolver().openOutputStream(uri, "wt");
					os.write(m_pendingExport.getBytes("UTF-8"));
					os.flush();
					os.close();
					ok = true;
				}
				catch (Exception e) {
					Log.i("yoyo", "FileTransfer export write failed: " + e.toString());
				}
			}
			m_pendingExport = "";
			int map = RunnerJNILib.jCreateDsMap(null, null, null);
			RunnerJNILib.DsMapAddString(map, "type", "filetransfer_export");
			RunnerJNILib.DsMapAddDouble(map, "success", ok ? 1 : 0);
			RunnerJNILib.CreateAsynEventWithDSMap(map, EVENT_OTHER_SOCIAL);
		}

		if (requestCode == REQ_IMPORT) {
			boolean ok = false;
			String txt = "";
			if (resultCode == Activity.RESULT_OK && data != null) {
				try {
					Uri uri = data.getData();
					InputStream is = RunnerActivity.CurrentActivity
						.getContentResolver().openInputStream(uri);
					BufferedReader r = new BufferedReader(new InputStreamReader(is, "UTF-8"));
					StringBuilder sb = new StringBuilder();
					String line;
					while ((line = r.readLine()) != null) {
						sb.append(line);
						sb.append("\n");
					}
					r.close();
					txt = sb.toString();
					ok = true;
				}
				catch (Exception e) {
					Log.i("yoyo", "FileTransfer import read failed: " + e.toString());
				}
			}
			int map = RunnerJNILib.jCreateDsMap(null, null, null);
			RunnerJNILib.DsMapAddString(map, "type", "filetransfer_import");
			RunnerJNILib.DsMapAddDouble(map, "success", ok ? 1 : 0);
			RunnerJNILib.DsMapAddString(map, "content", txt);
			RunnerJNILib.CreateAsynEventWithDSMap(map, EVENT_OTHER_SOCIAL);
		}
	}

} // End of class
