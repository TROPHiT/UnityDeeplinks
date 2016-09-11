using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UnityDeeplinks : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void onDeeplink(string deeplink) {
		Debug.Log("onDeeplink " + deeplink);
		Dictionary<string, string> values = new Dictionary<string, string>();
		values.Add("link", deeplink);
		AppsFlyer.trackRichEvent("deeplink", values);
	}
}
