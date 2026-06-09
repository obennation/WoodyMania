package funkin.states.options;

import funkin.backend.LanguageManager;

using StringTools;

class NoteSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = LanguageManager.get("options.notes");
		rpcTitle = 'Note Settings Menu'; // for Discord Rich Presence
		
		var option:Option = new Option(LanguageManager.get("notes.quantsenabled"), LanguageManager.get("notes.quantsenabled.text"), 'quants', BOOL, false);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("notes.notesplashes"), LanguageManager.get("notes.notesplashes.text"), 'noteSplashes', BOOL, true);
		addOption(option);
		
		var option:Option = new Option(LanguageManager.get("notes.opponentnotes"), LanguageManager.get("notes.opponentnotes.text"), 'opponentStrums', BOOL, true);
		addOption(option);
		
		// temporarily disabled
		// var option:Option = new Option('Customize', 'Change your note colours\n[Press Enter]', '', 'button', true);
		// option.callback = function() {
		// 	switch (ClientPrefs.noteSkin)
		// 	{
		// 		case 'Quants':
		// 			openSubState(new QuantNotesSubState());
		// 		case 'QuantStep':
		// 			openSubState(new QuantNotesSubState());
		// 		default:
		// 			openSubState(new NotesSubState());
		// 	}
		// }
		// addOption(option);
		
		super();
	}
}
