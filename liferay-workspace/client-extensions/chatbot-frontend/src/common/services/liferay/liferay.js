export const Liferay = window.Liferay || {
	// Removed from Q2.2026
	/*OAuth2: {
		getAuthorizeURL: () => '',
		getBuiltInRedirectURL: () => '',
		getIntrospectURL: () => '',
		getTokenURL: () => '',
		getUserAgentApplication: (_serviceName) => { },
	},
	OAuth2Client: {
		FromParameters: (_options) => {
			return {};
		},
		FromUserAgentApplication: (_userAgentApplicationId) => {
			return {};
		},
		fetch: (_url, _options = {}) => { },
	},*/
	ThemeDisplay: {
		getCompanyGroupId: () => 0,
		getScopeGroupId: () => 0,
		getSiteGroupId: () => 0,
		getPlid: () => 0,
		getUserId: () => 0,
		getLanguageId: () => 'en_US',
		isSignedIn: () => {
			return false;
		},
	},
	authToken: '',
};

export function isSignedIn() {
	return Liferay.ThemeDisplay.isSignedIn();
}

export function getOAuth2Client(erc) {

	if (!erc) {
		throw new Error("ERC (External Reference Code) is required");
	}

	if (typeof Liferay !== "undefined" && Liferay.OAuth2Client) {
		return Promise.resolve(
			Liferay.OAuth2Client.FromUserAgentApplication(erc)
		);
	}

	/* Magic comment to ignore module résolution at build time*/
	return import(/* webpackIgnore: true */ "@liferay/oauth2-provider-web/client").then(function (m) {
		return m.FromUserAgentApplication(erc);
	}).catch(function (error) {
		console.error("Error loading OAuth2 client module:", error);
		throw error;
	});
	
}