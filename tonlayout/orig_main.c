/*
src_url: https://stackoverflow.com/questions/3230761/how-to-change-keyboard-layout-a-x11-api-solution

Yesterday I was trying to make auto layuout switcher to EN for Google's xsecurelock. I tryed to find some existing solutions for X11 api, but...
So I decided to write my own with some help from S. Razi. Here is the code: (run with gcc -lX11)
Here you can change char* temp = "English" to name of the group of your layout (exmp: "Russian"), and this simple code will switch your current layout :)

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/XKBlib.h>

int main(){

  Display* _display;
  char* displayName = "";
  _display = XOpenDisplay(displayName);

  int _deviceId = XkbUseCoreKbd;
  int i = 0;
  int _groupCount = 0;

  XkbDescRec* kbdDescPtr = XkbAllocKeyboard();
  if (kbdDescPtr == NULL) {
  printf("%s\n", "Failed to get keyboard description."); 
  return False;
  }

  kbdDescPtr->dpy = _display;
  if (_deviceId != XkbUseCoreKbd) {
      kbdDescPtr->device_spec = _deviceId;
  }

  XkbGetControls(_display, XkbAllControlsMask, kbdDescPtr);
  XkbGetNames(_display, XkbSymbolsNameMask, kbdDescPtr);
  XkbGetNames(_display, XkbGroupNamesMask, kbdDescPtr);

  /* count groups */

  Atom* groupSource = kbdDescPtr->names->groups;
  if (kbdDescPtr->ctrls != NULL) {
      _groupCount = kbdDescPtr->ctrls->num_groups;
  } else {
      _groupCount = 0;
      while (_groupCount < XkbNumKbdGroups &&
             groupSource[_groupCount] != 0) {
          _groupCount++;
      }
  }

  /* get group names */
  Atom* tmpGroupSource = kbdDescPtr->names->groups;
  Atom curGroupAtom;
  char* groupName;
  for (i = 0; i < _groupCount; i++) {
      if ((curGroupAtom = tmpGroupSource[i]) != None) {
          char* groupNameC = XGetAtomName(_display, curGroupAtom);
              if (groupNameC == NULL) {
              continue;

          } else {
              groupName =  groupNameC;
              char *temp = "English";

              if (strncmp(temp, groupName, 7) == 0){
                  printf ("%s\n", groupName);
                  printf ("%d\n", i);
                  XkbLockGroup(_display, _deviceId, i);
                  XFree(groupNameC);
                  XCloseDisplay(_display);
              }
              return 0;
          }
      } 
  }
}
