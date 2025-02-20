unit CFX.Constants;

interface

const
  // CLASSES
  REGISTER_CLASS_NAME = 'CFX Main';
  REGISTER_CLASS_UTILS_NAME = 'CFX Utils';
  REGISTER_CLASS_LAYOUTS = 'CFX Layouts';
  REGISTER_CLASS_SHAPES = 'CFX Shapes';
  REGISTER_CLASS_EFFECTS_NAME = 'CFX Effects';
  REGISTER_CLASS_ANIM_NAME = 'CFX Animations';
  REGISTER_CLASS_LEGACY = 'CFX Legacy';

  // Strings
  STRING_NONE = 'none';

  // THEME MANAGER
  ACCENT_DIFFERENTIATE_CONST = 25;

  // API
  DEFAULT_API = 'https://api.codrutsoft.com/';
  DEFAULT_UPDATE_NAME = 'updateurl';
  DEFAULT_COMPANY = 'Codrut Software';

  // System interaction
  DEFAULT_SCROLL_LINES = 3;
  DEFAULT_LINE_SIZE = 25;

  // TIME
  ONE_MS = 1;
  FIFTH_SECOND = 200;
  ONE_SECOND = 1000;
  FIVE_SECOND = ONE_SECOND * 5;

  // COMPONENTS STYLE
  DEFAULT_OPACITY = 100;
  FORM_FONT_NAME = 'Segoe UI';
  FORM_FONT_HEIGHT = 22;
  FORM_SMOKE_BLEND_VALUE = 150;
  FORM_MICA_EFFECT_BLEND_VALUE = 251;

  LARGE_FONT_HEIGHT = -20;

  DARK_TINT_OPACITY = 75;
  LIGHT_TINT_OPACITY = 200;

  (* Functionality *)
  REPEAT_START_DELAY = 500;
  HOLD_REPEAT_INTERVAL = 50;

  SCROLL_DURATION = 1;
  SCROLL_SPEED_VALUE = 20;

  (* Composite the form with Parital Transparency *)
  FORM_COMPOSITE_COLOR = $00FF0083;

  (* Legacy, replaced by height *)
  FORM_FONT_SIZE_1 = 12;

  (* Use the ThemeManager.IconFont function to get the optimal font *)
  FORM_ICON_FONT_NAME_NEW = 'Segoe Fluent Icons';
  FORM_ICON_FONT_NAME_LEGACY = 'Segoe MDL2 Assets';

  TEXT_SIZE_COMPARER = 'ABC...';

  GENERAL_ROUND = 5;
  DEFAULT_GLASSTEXT_GLOWSIZE = 0;

  FOCUS_LINE_ROUND = 8;
  FOCUS_LINE_SIZE = 2;

  BUTTON_DEFAULT_HEIGHT = 35;
  BUTTON_DEFAULT_WIDTH = 140;
  BUTTON_COLOR_OFFSET = 10;
  BUTTON_COLOR_SMALL_OFFSET = 5;
  BUTTON_BLEND_FADE = 100;
  BUTTON_MARGIN = 5;
  BUTTON_ICON_SPACE = 30;
  BUTTON_IMAGE_SCALE = 1.25;
  BUTTON_ROUNDNESS = 10;
  BUTTON_STATE_DURATION = 1000;
  BUTTON_LINE_WIDTH = 3;
  BUTTON_STATE_TEXT = 'Success';

  LABEL_FONT_HEIGHT = 24;
  LABEL_FONT_NAME = FORM_FONT_NAME;

  SCROLLBAR_DEFAULT_SIZE = 40;
  SCROLLBAR_MIN_SIZE = 20;

  TOOLTIP_WIDTH = 2;
  TOOLTIP_FONT_NAME = FORM_FONT_NAME;
  TOOLTIP_FONT_SIZE = 8;
  TOOLTIP_ROUND = 5;

  CHECKBOX_ICON_SIZE = 22;
  CHECKBOX_BOX_ROUND = 6;
  CHECKBOX_TEXT_SPACE = 6;
  CHECKBOX_HINT_DURATION = 1000;

  PROGRESS_ACTIVELINE_SIZE = 4;
  PROGRESS_LINE_SIZE = 2;

  GENERAL_IMAGE_SCALE = 1.5;
  NORMAL_IMAGE_SCALE = 1;

  LIST_ITEM_OPACITY_SELECTED = 75;
  LIST_ITEM_OPACITY_HOVER = 35;

  RADIO_TEXT_SPACE = 6;

  SELECTOR_ROUND = 20;

  SLIDER_TICK_ROUND = 2;
  SLIDER_TICK_SPACING = 3;
  SLIDER_TICK_SIZE = 2;

  SCROLL_TEXT_SPACE = 75;
  SCROLL_TEXT_DELAY = 150;
  SCROLL_TEXT_SPEED = 1;
  SCROLL_TEXT_FADE_SIZE = 30;

  DEFAULT_SCROLLBAR_SIZE = 12;

  ICON_GREEN = 6277996;
  ICON_ICEBLUE = 14075312;
  ICON_YELLOW = 57852;
  ICON_ROSE = 10787327;

  PANEL_LINE_ROUND = 8;
  PANEL_LINE_SPACING = 10;
  PANEL_LINE_WIDTH = 8;

  HANDLE_SEPARATOR = 1;
  MINIMISE_PANEL_ROUND = 10;
  MINIMISE_PANEL_SIZE = 60;
  MINIMISE_ICON_MARGIN = 10;

  MINIMISE_COLOR_CHANGE = 5;

  EDIT_DEFAULT_WIDTH = 150;
  EDIT_DEFAULT_HEIGHT = 35;
  EDIT_COLOR_CHANGE = 10;
  EDIT_BORDER_FADE = 15;
  EDIT_BORDER_ROUND = 10;
  EDIT_LINE_SIZE = 2;
  EDIT_EXTRA_SPACE = 5;
  EDIT_INDIC_WIDTH = 1;
  EDIT_TEXT_HINT_FADE = 100;

  // Hint Class
  MAX_HINT_SIZE = 200;

  // TEXT
  CHECKBOX_OUTLINE = #$E003;
  CHECKBOX_SMALL = #$E004;
  CHECKBOX_CHECKED = #$E005;
  CHECKBOX_GRAYED = #$E73C;
  CHECKBOX_FILL = #$E73B;

  RADIO_FILL = #$E91F;
  RADIO_OUTLINE = #$ECCA;
  RADIO_BULLET = #$ECCC;

  SEGOE_UI_STAR = #$E734;

  TEXT_LIST_EMPTY = 'No items';

  TEXT_DEFAULT_GENERIC = 'Hello World';
  TEXT_LONG_GENERIC = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  // POPUP MENU
  POPUP_CAPTION_DEFAULT  = 'Popup Menu';

  POPUP_SPACING_TOPBOTTOM = 5;
  POPUP_SEPARATOR_HEIGHT = 1;
  POPUP_ITEM_HEIGHT = 35;
  POPUP_DECOR_OPACITY = 15;

  POPUP_ANIMATE_SIZE = 400;
  POPUP_ANIMATE_X_SIZE = 50;
  POPUP_MINIMUM_WIDTH = 215;
  POPUP_FRACTION_SPACE = 2;

  POPUP_LINE_SPACING = 10;
  POPUP_ITEM_SPACINT = 20;

  POPUP_RADIO = #$E915;
  POPUP_CHECKMARK = #$E73E;

  POPUP_TEXT_DISABLED = $808080;

  POPUP_ITEMS_OVERLAY_DISTANCE = 10;

  POPUP_SELECTION_ROUND = 15;
  POPUP_MENU_ROUND = 30;


implementation

end.
