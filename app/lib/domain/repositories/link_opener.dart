/// Hands a link to another app - the browser, the mail app.
///
/// The only way anything from Help leaves VocabNote, and only on a tap. Behind
/// an interface so a test can see what would have been opened without
/// opening it.
abstract interface class LinkOpener {
  /// Opens [uri] outside the app. False when nothing could open it - a phone
  /// with no mail app, say - which the caller must tell the user about.
  Future<bool> open(Uri uri);
}
