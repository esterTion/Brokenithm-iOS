#pragma once

#include <cstdio>
#include <conio.h>
#include <map>
#include <string>
using namespace std;

#include <windows.h>

#include <libimobiledevice\libimobiledevice.h>

void exitWithCode(int code);
bool initSharedMemory();
void device_event_callback(const idevice_event_t* event, void* user_data);

map<string, idevice_t*> device_map;
map<string, idevice_connection_t*> connection_map;

struct IPCMemoryInfo
{
    uint8_t airIoStatus[6];
    uint8_t sliderIoStatus[32];
    uint8_t ledRgbData[32 * 3];
};
typedef struct IPCMemoryInfo IPCMemoryInfo;
static HANDLE FileMappingHandle;
IPCMemoryInfo* FileMapping;

static DWORD connectDevice(LPVOID arg);
static DWORD readInputFromDevice(LPVOID arg);
