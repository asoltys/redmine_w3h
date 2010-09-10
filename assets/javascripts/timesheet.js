Event.observe(window, 'load', function() { 
  $$('tr.user td, tr.deliverable td, tr.activity td').each(function(e) { 
    e.observe('click', function(e) {
      toggleRow(e.element().up('tr'));
    });
  });

  $('expand').observe('click', function(e) {
    $$('table.list tr').invoke('show');
  });

  $('collapse').observe('click', function(e) {
    $$('table.list tr').each(collapse);
    $$('table.list tr.user').invoke('show');
  });
});

function toggleRow(row) {
  var img = row.select('img.toggle').first();

  if (row.classNames().include('collapsed')) {
    row.removeClassName('collapsed');
    img.src = '/images/arrow_expanded.png';
  } else {
    row.addClassName('collapsed');
    img.src = '/images/arrow_collapsed.png';
  }

  if (row.classNames().include('user')) { 
    until = 'user_end'; 
    child = 'deliverable'; 
  }
  if (row.classNames().include('deliverable')) { 
    until = 'deliverable_end'; 
    child = 'activity'; 
  }
  if (row.classNames().include('activity')) { 
    until = 'activity_end';
    child = 'time_entry';
  } 

  row.nextSiblings().each(function(e) {
    if (e.classNames().include(until)) throw $break; 
    if(row.classNames().include('collapsed')) {
      collapse(e);
    } else { 
      if (e.classNames().include(child)) {
        e.show();
      }
    }
  });
}

function collapse(row) {
  var img = row.select('img.toggle').first();
  row.hide();

  if (!img) return;

  row.addClassName('collapsed');
  row.select('img.toggle').first().src = '/images/arrow_collapsed.png';
}

