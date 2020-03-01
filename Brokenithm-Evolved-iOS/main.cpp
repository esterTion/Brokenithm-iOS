#include "main.h"
#pragma comment(lib, "libimobiledevice.lib")

int main(int argc, char** argv)
{
	idevice_set_debug_level(1);
	idevice_error_t status;
	status = idevice_event_subscribe(device_event_callback, NULL);
	if (status) {
		printf("Subscribe for device failed\n");
		exitWithCode(1);
	}
	if (!initSharedMemory()) {
		printf("Initialize shared memory failed\n");
		exitWithCode(1);
	}
	printf("Waiting for device...\n");
	while (_getch() != 'q') {}
	return 0;
}
void exitWithCode(int code) {
	printf("Press any key to exit...");
	_getch();
	exit(code);
}

bool initSharedMemory()
{
	if (FileMapping)
	{
		return true;
	}
	if ((FileMappingHandle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, sizeof(IPCMemoryInfo), L"Local\\BROKENITHM_SHARED_BUFFER")) == 0)
	{
		return false;
	}

	if ((FileMapping = (IPCMemoryInfo*)MapViewOfFile(FileMappingHandle, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(IPCMemoryInfo))) == 0)
	{
		return false;
	}

	memset(FileMapping, 0, sizeof(IPCMemoryInfo));
	return true;
}

void device_event_callback(const idevice_event_t* event, void* user_data)
{
	idevice_error_t status;
	bool isAdd = event->event == IDEVICE_DEVICE_ADD;
	printf("device %s\tudid: %s\n", isAdd ? "add" : "remove", event->udid);
	if (isAdd) {
		string udid = event->udid;
		if (device_map[udid]) return;
		idevice_t* device = new idevice_t;
		device_map[udid] = device;
		Sleep(1000);
		status = idevice_new(device, udid.c_str());
		if (status != IDEVICE_E_SUCCESS) {
			printf("Create device failed\n");
			device_map.erase(udid);
			delete device;
		}
		else {
			LPVOID arg = new string(udid);
			CloseHandle(CreateThread(NULL, 1, (LPTHREAD_START_ROUTINE)connectDevice, arg, 0, NULL));
		}
	}
	else {
		string udid = event->udid;
		idevice_t* device = device_map[udid];
		if (device) {
			device_map.erase(udid);
			status = idevice_free(*device);
			if (status != IDEVICE_E_SUCCESS) {
				printf("Free device failed\n");
			}
			delete device;
		}
	}
}

static DWORD connectDevice(LPVOID arg) {
	string udid = string(*(string*)arg);
	delete arg;
	idevice_t* device = device_map[udid];
	if (!device) return 1;

	idevice_connection_t *conn = new idevice_connection_t;
	idevice_error_t status;
	status = idevice_connect(*device, 24864, conn);
	if (status != IDEVICE_E_SUCCESS) {
		printf("connect failed: %d\n", status);
		delete conn;
		Sleep(5000);
		LPVOID arg = new string(udid);
		CloseHandle(CreateThread(NULL, 1, (LPTHREAD_START_ROUTINE)connectDevice, arg, 0, NULL));
		return 1;
	}

	char buf[1024];
	uint32_t read;
	status = idevice_connection_receive(*conn, buf, 4, &read);
	if (status != IDEVICE_E_SUCCESS) {
		printf("receive data failed: %d\n", status);
		idevice_disconnect(*conn);
		delete conn;
		return 1;
	}
	if (memcmp(buf, "\x03WEL", 4) != 0) {
		printf("received invalid data\n");
		idevice_disconnect(*conn);
		delete conn;
		return 1;
	}
	printf("connected to device\n");
	connection_map[udid] = conn;
	{
		LPVOID arg = new string(udid);
		CloseHandle(CreateThread(NULL, 1, (LPTHREAD_START_ROUTINE)readInputFromDevice, arg, 0, NULL));
	}
	return 0;
}

static DWORD readInputFromDevice(LPVOID arg) {
	string udid = string(*(string*)arg);
	delete arg;
	idevice_connection_t* conn = connection_map[udid];
	if (!conn) return 1;

	idevice_error_t status;
	char buf[1024];
	uint32_t read;
	while (true) {
		status = idevice_connection_receive_timeout(*conn, buf, 1, &read, 5);
		if (status != IDEVICE_E_SUCCESS) {
			printf("receive error: %d", status);
			if (status == IDEVICE_E_UNKNOWN_ERROR) {
				continue;
			}
		}
	}
}
