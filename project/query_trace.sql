WITH cte_que
AS
(
SELECT q.id, q.ip, 
		querytext, 
		timestart, 
		EXTRACT(EPOCH FROM (timefinish - timestart)) AS duration, 		
		array_agg('''' || p.value || '''' ORDER BY p.id) AS params
FROM pgparser.queries q
JOIN pgparser.params p ON p.queryid = q.id
WHERE querytext LIKE '%test_func%'
GROUP BY q.id, ip, 	port, 
		querytext, 
		timestart, 
		timefinish 
)
SELECT 
	id, ip, 
	querytext, 		
	REPLACE(REPLACE(REPLACE(querytext, '$1', COALESCE(params[1],'')), '$2', COALESCE(params[2],'')), '$3', coalesce(params[3],'')) AS readyquery,
	timestart, 
	duration
FROM cte_que
ORDER BY timestart, id;


/*
delete
FROM pgparser.queries;

delete
FROM pgparser.params;
*/