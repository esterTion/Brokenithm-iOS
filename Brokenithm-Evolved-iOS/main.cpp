#include <cstdio>
#include <conio.h>
#include <map>
#include <string>
using namespace std;

#include <libimobiledevice\libimobiledevice.h>

#pragma comment(lib, "libimobiledevice.lib")

void device_event_callback(const idevice_event_t* event, void* user_data);

int main(int argc, char** argv)
{
	idevice_error_t status;
	status = idevice_event_subscribe(device_event_callback, NULL);
	if (status) {
		printf("Subscribe for device failed\n");
	}
	while (_getch() != 'q') {}
	return 0;
}

map<string, idevice_t*> device_map;
void device_event_callback(const idevice_event_t* event, void* user_data)
{
	idevice_error_t status;
	bool isAdd = event->event == IDEVICE_DEVICE_ADD;
	printf("device %s\tudid: %s\n", isAdd ? "add" : "remove", event->udid);
	if (isAdd) {
		string udid = event->udid;
		//idevice_t* device = (idevice_t*)malloc(sizeof(idevice_t));
		idevice_t* device = new idevice_t;
		device_map[udid] = device;
		status = idevice_new(device, udid.c_str());
		if (status) {
			printf("Create device failed\n");
			device_map.erase(udid);
			delete device;
		}
	}
	else {
		string udid = event->udid;
		idevice_t* device = device_map[udid];
		if (device) {
			device_map.erase(udid);
			status = idevice_free(*device);
			if (status) {
				printf("Free device failed\n");
			}
			delete device;
		}
	}
}