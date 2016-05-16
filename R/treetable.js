
function toggleTree(x) {

  // invalidate level-dropdown
  var tableWrapper = $(x).closest(".dataTables_wrapper");
  var dropdown = tableWrapper.find(".tree-level-dropdown");
  dropdown.val(-1);

  $(x).toggleClass("tree-toggle-collapsed tree-toggle-expanded");

  var tr = $(x).closest('tr');
  var groupFromClassRegex = new RegExp("(?:^|\\s)(?:tree-group-)([^\\s]+)");
  var clickedGroup = tr.attr("class").match(groupFromClassRegex)[1];

  var group = clickedGroup.slice(0, -4);
  var tableJQuery = $(x).closest('table');

  collapseTr = tableJQuery.find("*[class*='tree-group-" + group + "']");
  regExpCollapse = new RegExp("(^|\\s)tree-group-" + group + "[0-9]");
  regExpExpand = new RegExp("(^|\\s)tree-group-" + group + "[0-9](_exp)?(\\s|$)");


  if($(x).hasClass("tree-toggle-collapsed")) {
    collapseTr = collapseTr.filter(function() {
      return(this.className.match(regExpCollapse));
    });
    collapseTr.hide();

    regExpCollapseToggles = new RegExp("(^|\\s)tree-group-" + group + "[0-9](_exp)(\\s|$)");
    collapseToggles = collapseTr.filter(function() {
      return(this.className.match(regExpCollapseToggles));
    });
    collapseToggles.find('.tree-toggle-expanded').toggleClass("tree-toggle-expanded tree-toggle-collapsed");
    collapseToggles.css('display: inline-block;');

  } else {
    collapseTr = collapseTr.filter(function() {
      return(this.className.match(regExpExpand));
    });
    collapseTr.show();
  }
}

function addTreeGroup(row, data) {
  $(row).addClass("tree-group-" + data[data.length - 1]);
}

function addTreeLevel(row, data) {
  $(row).addClass("tree-level-" + data[data.length - 2]);
}

function addLevelDropdown(settings) {

  var table = new $.fn.dataTable.Api(settings);
  var tableJQuery = $(table.table().node());

  var nCols = table.columns()[0].length;
//  var levelDropdown = tableJQuery.find(".tree-dropdown-level");

  var tableWrapper = tableJQuery.closest(".dataTables_wrapper");
  var levelDropdownContainer = tableWrapper.find(".tree-level-dropdown-container");

  levelDropdownContainer.html(
    "<label>Zeige Level \
      <select class = 'tree-level-dropdown' onchange = 'levelChanged(this);'> \
      </select> \
    </label>"
  );

  var levelDropdown = levelDropdownContainer.find(".tree-level-dropdown");
  var levels = table.column(nCols - 2).data().unique().sort();
  for (i = 0; i < levels.length; i++) {
    levelDropdown.append($("<option />").text(levels[i]));
  }
  levelDropdown.val(-1);
}

function levelChanged(dropdown) {
  var tableWrapper = $(dropdown).closest(".dataTables_wrapper");
  var tableJQuery = tableWrapper.find(".dataTable");
  var table = tableJQuery.DataTable();

  var nCols = table.columns()[0].length;
  var levelSelected = jQuery.makeArray(parseInt($(dropdown).val()));

  var allLevels = table.column(nCols - 2).data().unique();
  var levelsBelow = jQuery.makeArray(allLevels.filter(function(x) {return x < levelSelected}));
  var levelsAbove = jQuery.makeArray(allLevels.filter(function(x) {return x > levelSelected}));

  // show rows with selected level or lower than selected
  var levelSameOrBelow = levelsBelow.concat(levelSelected);
  for (var i = 0; i < levelSameOrBelow.length; i++) {
    tableJQuery.find(".tree-level-" + levelSameOrBelow[i]).show();
  }

  // hide rows with higher levels than selected
  for (var i = 0; i < levelsAbove.length; i++) {
    tableJQuery.find(".tree-level-" + levelsAbove[i]).hide();
  }

  // set toggle icons of levels below the selected to expanded
  for (var i = 0; i < levelsBelow.length; i++) {
    var rowsToExpand = tableJQuery.find(".tree-level-" + levelsBelow[i]);
    var toggleToExpand = rowsToExpand.find(".tree-toggle-collapsed");
    if(toggleToExpand.length > 0) {
      toggleToExpand.toggleClass("tree-toggle-expanded tree-toggle-collapsed");
    }
  }

  // set toggle icons of selected level and above to collapsed
  var levelSameOrAbove = levelSelected.concat(levelsAbove);
  for (var i = 0; i < levelSameOrAbove.length; i++) {
    var rowsToCollapse = tableJQuery.find(".tree-level-" + levelSameOrAbove[i]);
    var toggleToCollapse = rowsToCollapse.find(".tree-toggle-expanded");
    if(toggleToCollapse.length > 0) {
      toggleToCollapse.toggleClass("tree-toggle-expanded tree-toggle-collapsed");
    }
  }
}


function addCustomSearch(settings) {
  var table = new $.fn.dataTable.Api(settings);
  var tableJQuery = $(table.table().node());

  var tableWrapper = tableJQuery.closest(".dataTables_wrapper");
  var searchInput = tableWrapper.find(".dataTables_filter").find("input");

  searchInput.off();
  searchInput.on("input", applySearch);
}

Array.prototype.unique = function() {
    var o = {}, i, l = this.length, r = [];
    for(i=0; i<l;i+=1) o[this[i]] = this[i];
    for(i in o) r.push(o[i]);
    return r;
};

function applySearch(e) {

  var value = $(this).val();
  var tableWrapper = $(this).closest(".dataTables_wrapper");
  var tableJQuery = tableWrapper.find(".dataTable");
  var table = tableJQuery.DataTable();
  var nCols = table.columns()[0].length;
  var nRow = table.rows()[0].length;
  var data = table.rows().data();

  // Reset current level dropdown
  var dropdown = tableWrapper.find(".tree-level-dropdown");
  dropdown.val(-1);

  // Find groups fulfilling search argument excluding toggable-column
  var filteredGroups = [];
  var regexNonToggable = new RegExp(".*" + value + ".*");
  for(col = 0; col < nCols; col++) {
    if(!([0, nCols - 2, nCols - 1].indexOf(col) > -1)) {
      for(row = 0; row < nRow; row++) {
        if(regexNonToggable.test(data[row][col])) {
          filteredGroups.push(data[row][nCols - 1]);
        }
      }
    }
  }

  // Find groups fulfilling search in toggable-column
  var regexToggable = new RegExp(".*(<span>)(.*" + value + ".*)(</span>)");
  for(row = 0; row < nRow; row++) {
    if(regexToggable.test(data[row][0])) {
      filteredGroups.push(data[row][nCols - 1]);
    }
  }

  var filteredGroups = filteredGroups.unique();

  // TODO: make optional
  // add parents of each filteredGroup
  var parentGroups = [];
  for(i = 0; i < filteredGroups.length; i++) {
    for(n = 1; n < filteredGroups[i].length; n++) {
      parentGroups.push(filteredGroups[i].slice(0, -n) + "_exp");
    }
  }
  var parentGroups = parentGroups.unique();

  var groupsToShow = filteredGroups.concat(parentGroups);

  // hide and show rows depending on filter
  var allGroups =  table.column(nCols - 1).data().unique();
  for(i = 0; i < allGroups.length; i++) {
    var tr = tableJQuery.find(".tree-group-" + allGroups[i]);
    if(groupsToShow.indexOf(allGroups[i]) > -1) {
      tr.show();
    } else {
      tr.hide();
    }
  }
}


$.fn.dataTable.ext.order['group'] = function(settings, col) {

  // load group and clicked (= value) column data
  var table = new $.fn.dataTable.Api(settings);
  var tableJQuery = $(table.table().node());
  var nCols = table.columns()[0].length;
  var group = table.column(nCols - 1).data();

  for(i = 0; i < group.length; i++) {
    group[i] = group[i].replace(/(_exp)/, "");
  }

  var value = [];
  if(col == 0){
    value = table.rows().indexes();
  } else {
    value = table.column(col).data();
  }
  // bind row data together
  a = [];
  for(i = 0; i < group.length; i++) {
    var tmp = [];
    tmp.push(group[i]);
    tmp.push(value[i]);
    a.push(tmp);
  }

  // split data into level groups
  lvl = [];
  for(i = 0; i < a.length; i++) {
  	if(typeof lvl[a[i][0].length - 1] == 'undefined'){
    	lvl[a[i][0].length - 1] = [];
    }
    lvl[a[i][0].length - 1].push(a[i]);
  };

  // sort all level groups accoring to their "value"
  var sortInfo = table.settings().order();
  var sortCol = sortInfo[0][0]; // counting from left, starting with 0
  var sortDir = sortInfo[0][1]; // either "asc" or "desc"

  function sortAsc(a, b) {
    return a[1] - b[1];
  };

  function sortDesc(a, b) {
    return b[1] - a[1];
  };

  for(i = 0; i < lvl.length; i++) {
    if(sortDir == "asc") {
      lvl[i].sort(sortAsc);
    } else if(sortDir == "desc") {
      lvl[i].sort(sortDesc);
    }
  };

  // remove values and make arrays group arrays only
  lvlGroup = [];
  for(i = 0; i < lvl.length; i++) {
    if(typeof lvlGroup[i] == 'undefined'){
    	lvlGroup[i] = [];
    }
    for(j = 0; j < lvl[i].length; j++) {
      lvlGroup[i].push(lvl[i][j][0]);
    }
  };


  // evaluate new order
  var orderedGroups = lvlGroup[0].slice();
  for(i = 1; i < lvlGroup.length; i++) {
    var parentGroup = "";
    var parentIndex = -1;
  	for(j = lvlGroup[i].length - 1; j >= 0; j--) {
    	var currentParentGroup = lvlGroup[i][j].slice(0, -1);
   		if(currentParentGroup != parentGroup) {
      	parentGroup = currentParentGroup;
        parentIndex = orderedGroups.indexOf(parentGroup);
      }
      orderedGroups.splice(parentIndex + 1, 0, lvlGroup[i][j]);
    }
  }

  // current indices in grouped order
  var groupOrigIndex = table.column(nCols - 1, {order: 'index'}).data();
  for(i = 0; i < groupOrigIndex.length; i++) {
    groupOrigIndex[i] = groupOrigIndex[i].replace(/(_exp)/, "");
  }
  var orderedIndices = [];
  for(i = 0; i < groupOrigIndex.length; i++) {
  	orderedIndices.push(orderedGroups.indexOf(groupOrigIndex[i]));
  }

  if(sortDir == "desc") {
   for(i = 0; i < orderedIndices.length; i++) {
    orderedIndices[i] = orderedIndices.length - orderedIndices[i] - 1;
    }
  }

  return(orderedIndices);
};




