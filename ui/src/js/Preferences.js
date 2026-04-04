const getPreferencesInstall = () => {
  const preferences_install = localStorage.getItem("preferences_install");
  return preferences_install;
};

const initPreferences = (app) => {
  app.ports.savePreferencesInstallString.subscribe((preferences_install) => {
    localStorage.setItem("preferences_install", preferences_install);
  });
};

export
  { getPreferencesInstall
  , initPreferences
  };
